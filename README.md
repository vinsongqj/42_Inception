*This project has been created as part of the 42 curriculum by vgoh*

# Inception

## Description

Inception is a system administration project designed to introduce containerization and infrastructure management using Docker and Docker Compose. DockerHub and the use of Docker images is forbidden, and every service must be built using custom Dockerfiles based on the penultimate distribution of either Debian or Alpine. Debian is used for this project.

### Mandatory Services:
* **NGINX** - Acts as the sole entry point listening on port 443 with TLS v1.2/v1.3. It routes web traffic and proxies PHP requests to WordPress.
* **WordPress + PHP-FPM** - Runs the dynamic backend (without NGINX inside this container).
* **MariaDB** - Database container for WordPress storage.
* **Volumes** - Configured using bind mounts mapped to `/home/<user>/data` to ensure database records and site files survive container reboots.
* **Docker Network** - An isolated internal bridge network allowing containers to communicate via DNS resolution using service names.

### Bonus Services:
* **Redis** - Dedicated in-memory caching container paired with WordPress to speed up repeated reads and reduce database load.
* **Static Website** - Separate containerized site serving static web assets routed through NGINX without needing PHP or database overhead.

## Instructions

## Project Description

### Virtual Machines vs Docker

A Virtual Machine uses hypervisor, which is a software, firmware, or hardware layer that abstracts physical computer hardware to simulate a computer. It boots a kernel, loads hardware drivers and runs its own OS (operating system).

Meanwhile, Docker is an open-source platform that packages an application and all its dependencies into a standardized, isolated unit called a container. A Docker container is a Linux process that does not need to boot, shares the kernel and uses just the application's memory. However, they differ in the sense that normal processes are aware of each other, share the same filesystem, network interface and host name. A Docker container is assigned a PID (Process ID) namespace and isolated by the kernel, so it believes it is the first process running on an empty system, hence PID 1.

A process isolated by a PID namespace can still consume all the host CPU and crash the machine. This is solved by the kernel using cgroups (control groups), that allows memory and cpu flags to configure the usage limits of each process. If a process requires more memory, a cgroup will attempt to reclaim existing memory already being used by the process to be reused, or if memory usage exceeds limits, the process is killed.

Below is a brief comparison between virtual machines and Docker:

| | Virtual Machines | Docker |
| :--- | :---: | :---: |
| **Architecture** | Fully virtual and running on hypervisor, with its own OS and kernel | Isolated Linux process that shares the host OS kernel |
| **Memory Footprint** | Large, needs to allocate RAM, CPU and drive space for its own OS  | Small, needs to just run the app and its own runtime overhead |
| **Startup** | Slow, needs to boot OS and load drivers | Fast, does not need to boot OS |
| **Isolation** | Separate OS instance enforced by hypervisor | Isolated, process believes it is running alone due to kernel namespace isolation, hence PID 1 |
| **Resource Usage** | Virtual CPU, RAM and disk allocated by hypervisor | CPU and RAM usage enforced by cgroups that will reclaim memory if a process requires more or kill it if it exceeds usage limits |

Essentially, Docker is used for speed and efficiency, while virtual machines are used for strict isolation and security.

### Secrets vs Environment Variables

Secrets are sensitive credentials delivered securely to containers as read-only, in-memory files (typically mounted under `/run/secrets/`). They prevent accidental exposure by keeping sensitive data out of environment listings, build histories, image layers, and process dumps.

Environment variables are key-value pairs injected directly into a container's OS environment at launch. They are simple to use and ideal for non-sensitive configuration settings but they sit in plaintext in process memory and output across `docker inspect`, `/proc`, and crash logs.

| | Docker Secrets | Environment Variables |
| :--- | :---: | :---: |
| **Delivery** | Mounted as files in memory (e.g., `/run/secrets/<name>`) | Passed into the process environment (`-e`, `--env-file`, `ENV`) |
| **Crash Dumps & Logs** | Safer, not automatically dumped with process environment blocks | Riskier, often leaked into error reports, debug logs, or crash dumps |
| **Child Processes** | Only accessible if explicitly read by code with file permission | Automatically inherited by child processes and subshells by default |
| **Inspection and Debugging** | Hidden from `env` and `docker inspect` environment output | Visible in `env`, `/proc/<pid>/environ`, and `docker inspect` |
| **Access Control** | Controlled by file permissions, read-only mounts, and container scope | All within the container's process environment |
| **Usage** | Passwords, API keys, tokens, private keys | Non-sensitive config (ports, log levels, feature flags) |

### Docker Network vs Host Network

### Docker Volumes vs Bind Mounts

## Resources
* [Docker Docs](https://docs.docker.com/)
* [Docker Under the Hood (Finally Explained) - PawelCodeStuff](https://youtu.be/uG68z0ss-is?si=HWljhYAIgzNQdrvm)
* [Docker Secrets vs Env Variables Explained - Interview Mentor App](https://youtu.be/UuwM03KX_BU?si=wnyAPj6-hhBuWkAl)
* [How TLS Works: The Protocol That Keeps Your Passwords Secret - PawelCodeStuff](https://youtu.be/NoFNP0Vy4tY?si=UUZZ7Vey8GFckiHu)
* [Nginx will finally make sense after this video - PawelCodeStuff](https://youtu.be/L0jMBrCEQNQ?si=Yosv0wsM6CN6OHBW)
* [How Nginx and PHP-FPM turn a web request into code](https://youtu.be/lh4RnczaATI?si=Hb0DeuCvZ_qk9FIB)

### Disclosure of AI usage

Claude was used specifically to learn the commands used to write the scripts, Dockerfile, docker_compose.yml and to help me with troubleshooting whenever I got stuck at a step.
