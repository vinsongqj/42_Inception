# Developer documentation

This document explains how to set up, build, run and maintain the project. For day-to-day use of the site, see `USER_DOC.md`.

## Repository layout

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                    (gitignored, created locally)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env                    (gitignored, created locally)
    ├── .env.example
    └── requirements/
        ├── mariadb/    (Dockerfile, conf/, tools/)
        ├── wordpress/  (Dockerfile, conf/, tools/)
        ├── nginx/      (Dockerfile, conf/)
        └── bonus/
            ├── redis/
            └── static/
```

Each service has its own Dockerfile, built from `debian:bookworm` (the penultimate stable Debian). No ready-made images are pulled, and the `latest` tag is never used.

## Set up the environment from scratch

### 1. Prerequisites

- A Debian virtual machine, with a user whose name is your login (the data path is `/home/<login>/data`).
- Docker Engine and the Docker Compose plugin, installed from Docker's official apt repository.
- `make`, `git`, `curl`, and `sudo`.

Install the basics:

```bash
sudo apt update && sudo apt install -y git make curl ca-certificates sudo
```

Verify Docker (add your user to the `docker` group, then log out and in again):

```bash
sudo usermod -aG docker $USER
docker run --rm hello-world
docker compose version
```

### 2. Map the domain to the machine

```bash
echo "127.0.0.1 vgoh.42.fr" | sudo tee -a /etc/hosts
```

When browsing from another computer (for example the host of the VM), add the same name to that computer's hosts file and forward port 443 to the VM.

### 3. Clone the repository

```bash
git clone <repo-url> inception && cd inception
```

### 4. Create the configuration file

```bash
cp srcs/.env.example srcs/.env
```

Edit `srcs/.env` if needed. The format is `NAME=value`, with no quotes and no spaces around `=`.

| Variable | Purpose |
|---|---|
| `DOMAIN_NAME` | Domain used for the certificate, nginx `server_name` and the WordPress URL |
| `MYSQL_DATABASE` | Name of the WordPress database |
| `MYSQL_USER` | Database user WordPress connects with |
| `WP_TITLE` | Site title |
| `WP_ADMIN_USER` | Administrator username. It must **not** contain "admin" or "administrator" |
| `WP_ADMIN_EMAIL` | Administrator email |
| `WP_USER` | Second user's username |
| `WP_USER_EMAIL` | Second user's email |

### 5. Create the secrets

`secrets/` is gitignored, so it has to be created after every fresh clone, **before** running `make`:

```bash
mkdir -p secrets
printf '%s' '<db password>'       > secrets/db_password.txt
printf '%s' '<db root password>'  > secrets/db_root_password.txt
printf '%s\n%s\n' '<wp admin password>' '<wp user password>' > secrets/credentials.txt
chmod 600 secrets/*.txt
```

- Use `printf '%s'` so no trailing newline ends up in the password.
- If a secret file is missing when compose starts, Docker may create a directory with that name, and the container fails with "Is a directory". Remove the directory and create the file.
- Never commit these files or put real passwords in any tracked file.

## Build and launch

The Makefile wraps Docker Compose. It creates the data folders, builds the images and starts the containers.

```bash
make         # build and start all containers in the background
make down    # stop and remove the containers, keep the data
make clean   # make down, then prune dangling images
make fclean  # remove containers, volumes, images and the host data folders
make re      # fclean, then make
```

Behind `make`, the main command is:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

The data location is defined in the Makefile as `DATA_DIR = /home/$(USER)/data` and exported, so compose can read `${DATA_DIR}`. If you run `docker compose` by hand, export it first, or compose warns about a blank variable:

```bash
export DATA_DIR=/home/$USER/data
```

On a first start WordPress is downloaded and installed by the entrypoint script, which takes a minute or two. Until that finishes, nginx may answer with a 403.

## Useful commands

```bash
export DATA_DIR=/home/$USER/data
docker compose -f srcs/docker-compose.yml ps               # container status
docker compose -f srcs/docker-compose.yml logs -f nginx    # follow one service's logs
docker compose -f srcs/docker-compose.yml build --no-cache wordpress   # rebuild one image
docker compose -f srcs/docker-compose.yml config           # validate and print the resolved file
docker ps -a                       # all containers, including exited ones
docker logs <container>            # output of the container's main process
docker exec -it <container> sh     # shell inside a container
docker top <container>             # processes inside; PID 1 should be the real service
docker network ls                  # the project network (srcs_inception)
docker volume ls                   # named volumes
docker volume inspect <volume>     # shows the host path under /home/<login>/data
```

Quick checks:

```bash
curl -k -I https://vgoh.42.fr                          # HTTP 200 or redirect
curl -I http://vgoh.42.fr                              # must fail (port 80 closed)
openssl s_client -connect vgoh.42.fr:443 -tls1_2 < /dev/null | grep Protocol
docker exec nginx nginx -t                             # validate the nginx config
docker exec wordpress wp user list --allow-root --path=/var/www/html
docker exec -it mariadb mariadb -u root -p             # then: SHOW DATABASES;
docker exec wordpress wp redis status --allow-root --path=/var/www/html
```

Configuration files are copied into the images at build time. After editing a Dockerfile, script or config file, run `make` again so the image is rebuilt and the container is recreated.

## How the services work

- **MariaDB**: `tools/init.sh` runs as the entrypoint. If `/var/lib/mysql/mysql` does not exist yet, it initializes the data directory and runs the setup SQL once (root password, database, user with host `%`), reading passwords from `/run/secrets/`. It then ends with `exec mariadbd`, so MariaDB is PID 1. It listens on `0.0.0.0` inside the Docker network only.
- **WordPress**: `tools/setup.sh` waits for MariaDB with a bounded retry loop, then downloads WordPress, creates `wp-config.php`, installs the site, creates the second user, configures the Redis cache, fixes file ownership and ends with `exec php-fpm8.2 -F`. Every step checks whether it was already done, so the script is safe to run on each start. php-fpm listens on port 9000.
- **NGINX**: terminates TLS (1.2 and 1.3 only) with a self-signed certificate generated at build time, serves static files from the shared WordPress volume, forwards `.php` requests to `wordpress:9000` over FastCGI, and proxies `/portfolio/` to the static container.
- **Redis** (bonus): in-memory object cache for WordPress, reachable only on the Docker network, with no volume.
- **Static** (bonus): a small nginx container serving the portfolio files copied into its image.

Only nginx publishes a port (`443:443`). Passwords are mounted as Docker secrets under `/run/secrets/`.

## Where the data is stored and how it persists

Two named volumes, defined in `srcs/docker-compose.yml` with the local driver options `type: none`, `o: bind` and `device: ${DATA_DIR}/...`, so their data lives on the host:

| Volume | Container path | Host path |
|---|---|---|
| `db_data` | `/var/lib/mysql` | `/home/<login>/data/mariadb` |
| `wp_data` | `/var/www/html` | `/home/<login>/data/wordpress` |

Compose prefixes the names with the project name (for example `srcs_db_data`). Verify with:

```bash
docker volume ls
docker volume inspect srcs_db_data | grep device
```

Persistence behavior:

- `make down` (and a machine reboot followed by `make`) keeps the data. The init and setup scripts detect existing data and skip the one-time setup.
- `make fclean` deletes the volumes and the contents of `/home/<login>/data`, so the next start installs everything again.
- The database user and passwords are created only on empty data. If you change `.env` or the secrets after a first start, run `make fclean` first, otherwise MariaDB keeps the old values and WordPress cannot log in.

## Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| `make` fails on volume creation | The data folders are missing or `DATA_DIR` is empty. Run through `make`, or `export DATA_DIR=/home/$USER/data`. |
| WordPress container exits with "MariaDB unreachable" | Wrong or stale credentials. Check `srcs/.env` and `secrets/`, then `make fclean && make`. |
| Site returns 403 right after start | WordPress is still installing. Check `docker logs wordpress` and wait. |
| 502 Bad Gateway | The `wordpress` container is down or restarting. Read its logs. |
| 504 Gateway Timeout | php-fpm waits on a dependency (for example Redis). Check `docker ps` and the logs. |
| "Is a directory" error for a secret | The secret file was missing at startup. Delete the directory and create the file. |
| Compose warns `DATA_DIR` is not set | Run through `make`, or export the variable first. |
