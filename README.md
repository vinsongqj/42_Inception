*This project has been created as part of the 42 curriculum by vgoh*

# Inception

## Description

## Instructions

## Project Description

### Virtual Machines vs Docker

A Virtual Machine uses hypervisor, which is a software, firmware, or hardware layer that abstracts physical computer hardware to simulate a computer. It boots a kernel, loads hardware drivers and runs its own OS (operating system).

Meanwhile, Docker is an open-source platform that packages an application and all its dependencies into a standardized, isolated unit called a container. A Docker container is a Linux process that does not need to boot, shares the kernel and uses just the application's memory. However, they differ in the sense that normal processes are aware of each other, share the same filesystem, network interface and host name. A Docker container is assigned a PID (Process ID) namespace and isolated by the kernel, so it believes it is the first process running on an empty system, hence PID 1.

A process isolated by a PID namespace can still consume all the host CPU and crash the machine. This is solved by the kernel using cgroups (control groups), that allows memory and cpu flags to configure the usage limits of each process. If a process requires more memory, a cgroup will attempt to reclaim existing memory already being used by the process to be reused, or if memory usage exceeds limits, the process is killed.

Below is a brief comparison between virtual machines and Docker:

| | Virtual Machines | Docker |
| :--- | :---: | :---: |
| Architecture | Fully virtual and running on hypervisor, with its own OS and kernel | Isolated Linux process that shares the host OS kernel |
| Memory Footprint | Large, needs to allocate RAM, CPU and drive space for its own OS  | Small, needs to just run the app and its own runtime overhead |
| Startup | Slow, needs to boot OS and load drivers | Fast, does not need to boot OS |
| Isolation | Separate OS instance enforced by hypervisor | Isolated, process believes it is running alone due to kernel namespace isolation, hence PID 1 |
| Resource Usage | Virtual CPU, RAM and disk allocated by hypervisor | CPU and RAM usage enforced by cgroups that will reclaim memory if a process requires more or kill it if it exceeds usage limits |

Essentially, Docker is used for speed and efficiency, while virtual machines are used for strict isolation and security.

### Secrets vs Environment Variables

### Docker Network vs Host Network

### Docker Volumes vs Bind Mounts

## Resources
* [Docker Docs](https://docs.docker.com/)
* [Docker Under the Hood (Finally Explained) - PawelCodeStuff](https://youtu.be/uG68z0ss-is?si=HWljhYAIgzNQdrvm)
* [How TLS Works: The Protocol That Keeps Your Passwords Secret - PawelCodeStuff](https://youtu.be/NoFNP0Vy4tY?si=UUZZ7Vey8GFckiHu)
* [Nginx will finally make sense after this video - PawelCodeStuff](https://youtu.be/L0jMBrCEQNQ?si=Yosv0wsM6CN6OHBW)
* [How Nginx and PHP-FPM turn a web request into code](https://youtu.be/lh4RnczaATI?si=Hb0DeuCvZ_qk9FIB)

### Disclosure of AI usage

Claude was used specifically to learn the commands used to write the scripts, Dockerfile, docker_compose.yml and to help me with troubleshooting whenever I got stuck at a step.
