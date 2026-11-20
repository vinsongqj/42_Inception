*This project has been created as part of the 42 curriculum by vgoh*

# Inception

## Description

## Instructions

## Project Description

### Virtual Machines vs Docker

| | Virtual Machines | Docker |
| :--- | :---: | :---: |
| Architecture | Fully virtual and running on hypervisor, with its own OS and kernel | Isolated Linux kernel that shares the host OS kernel |
| Memory Footprint | Large, needs to allocate RAM, CPU and drive space for its own OS  | Small, needs to just run the app and its own runtime overhead |
| Startup | Slow, needs to boot OS and load drivers | Fast, does not need to boot OS |
| Isolation | Separate OS instance enforced by hypervisor | Isolated, process believes it is running alone due to kernel namespace isolation, hence PID 1 (Process ID 1)|
| Resource Usage | Virtual CPU, RAM and disk allocated by hypervisor | CPU and RAM usage enforced by cgroups that will reclaim memory if a process requires more or kill it if it exceeds usage limits |

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
