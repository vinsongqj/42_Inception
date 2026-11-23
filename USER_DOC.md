# User documentation

This document explains how to use the Inception stack as an end user or administrator. For building and modifying the project, see `DEV_DOC.md`.

## Services provided

| Service | Role | Reachable from outside? |
|---|---|---|
| **NGINX** | Web server and reverse proxy. The only entrypoint, HTTPS on port 443 (TLS 1.2/1.3). | Yes, port 443 |
| **WordPress** | WordPress website running on php-fpm. | No, internal only |
| **MariaDB** | Database that stores the WordPress content and users. | No, internal only |
| **Redis** (bonus) | Object cache that speeds up WordPress. | No, internal only |
| **Static** (bonus) | Static portfolio website, served through nginx. | Via `https://vgoh.42.fr/portfolio/` |

All services run in separate Docker containers on a private Docker network. Only nginx publishes a port.

## Start and stop

Run these commands from the root of the repository.

```bash
make         # build and start everything
make down    # stop and remove the containers, keeping all data
make fclean  # remove everything, including the website and database data
make re      # rebuild everything from scratch (deletes data)
```

- The first start takes a minute or two, because WordPress is downloaded and installed. During that time the site may show a 403 or an empty page. Wait until `docker logs wordpress` shows that WordPress was installed successfully.
- After a reboot of the machine, run `make` again to start the stack.
- `make down` keeps your data. `make fclean` deletes it permanently.

## Access the website and the administration panel

The domain `vgoh.42.fr` must resolve to the machine that runs the stack (an entry `127.0.0.1 vgoh.42.fr` in `/etc/hosts`).

| What | URL |
|---|---|
| Website | `https://vgoh.42.fr` |
| Administration panel | `https://vgoh.42.fr/wp-admin` |
| Static site (bonus) | `https://vgoh.42.fr/portfolio/` |

The site uses a self-signed certificate, so the browser shows a security warning. Accept it to continue. Plain `http://` is not served, because port 80 is closed.

## Credentials

Two WordPress accounts exist:

| Account | Username | Password | Role |
|---|---|---|---|
| Administrator | `WP_ADMIN_USER` in `srcs/.env` | line 1 of `secrets/credentials.txt` | administrator |
| Second user | `WP_USER` in `srcs/.env` | line 2 of `secrets/credentials.txt` | author |

Where the credentials live:

- `srcs/.env` holds non-secret settings (domain, database name, usernames, emails).
- `secrets/db_password.txt` is the password of the WordPress database user.
- `secrets/db_root_password.txt` is the MariaDB root password.
- `secrets/credentials.txt` holds the WordPress passwords (line 1 administrator, line 2 second user).

Both `srcs/.env` and `secrets/` are excluded from git. Keep a private backup of them, because they cannot be recovered from the repository.

To read a value:

```bash
grep WP_ADMIN_USER srcs/.env
sed -n 1p secrets/credentials.txt
```

Passwords are applied the first time the stack starts on empty data. Changing a file afterwards has no effect until you run `make fclean` and start again. To change a WordPress password without wiping data, use the profile page in the administration panel.

## Check that the services are running

```bash
docker ps
```

All containers should show `Up` (`mariadb`, `wordpress`, `nginx`, and with the bonus `redis` and `static`). Further checks:

```bash
curl -k -I https://vgoh.42.fr        # expect HTTP 200 or a redirect
curl -I http://vgoh.42.fr            # expect a connection failure
docker logs wordpress                # setup and php-fpm messages
docker logs mariadb                  # database messages
docker logs nginx                    # web server messages
```

Useful sign that everything works:

- The website loads at `https://vgoh.42.fr` and shows the WordPress site, not the installation page.
- You can sign in at `/wp-admin` with the administrator account.
- A change made in the administration panel appears on the website.

If a container keeps restarting, read its log with `docker logs <name>`. If the site returns an error right after startup, wait a minute and reload.

Cache check (bonus):

```bash
docker exec wordpress wp redis status --allow-root --path=/var/www/html
```

The status should read `Connected`.
