#### Traditional Setup 

---

  - Physical Servers 
  - Virtual Servers 

![VMS](https://www.veeam.com/blog/wp-content/uploads/2015/10/2015-Q4-Physical-Servers-vs-VMs.png)

---

#### Containers Basics 

![Docker+Container](https://alleslinux.com/wp-content/uploads/2016/10/container-docker-blue-whale.jpg)

---

### WHAT IS A CONTAINER?

---

  - A stand-alone executable package that contains:
      - Code
      - Runtime
      - System tools
      - Libraries
      - Setting
  - Isolates software from its surroundings

---

### HOW DO THEY DIFFER FROM A VM?

---
![Containervsvm](http://windowsitpro.com/site-files/windowsitpro.com/files/uploads/2015/01/docker%20overview.jpg)

---

### Why Containers ?

+++
Four key benefits of using containers
+++
## Portable
Image can be ship, it’s mutable, image has versions
+++
## Flexible 
You can create clean, reprodusable and moduler environment
+++
## Fast
Speed at start quickly containers, Caching layer of docker make faster build container
+++
## Efficient
We can allocate exactly resource we want like cpu,memory, it does require full operating system.

---

### Container Platform 

  - Docker ( we are using this )
  - AWS ECS
  - LXD
  - LXC
  - RKT
  
---

### Terminologies 

++

An **image** is a lightweight, stand-alone, executable package that includes everything needed to run a piece of software, including the code, a runtime, libraries, environment variables, and config files.

<span class="fragment">Explore and share images on [Docker Hub](https://hub.docker.com/)</span>   
+++

A **Dockerfile** is a text document that contains all the commands a user could call on the command line to assemble an image.

+++

Example `Dockerfile`:

```
FROM ubuntu:latest
MAINTAINER Rahul Patil <rahul.patil@veon.com> 

RUN apt-get update
RUN apt-get install -y python python-pip wget
RUN pip install Flask

ADD hello.py /home/hello.py

WORKDIR /home

CMD ["python", "hello.py"]
```

+++

A **container** is a runtime instance of an image – what the image becomes in memory when actually executed.

It runs completely isolated from the host environment by default, only accessing host files and ports if configured to do so.

+++

A **volume** is a specially-designated directory within one or more containers that are designed to persist data, independent of the container’s life cycle (also known as *data volume*).

---

### Basic usage of the `docker` CLI

+++

Build image from `Dockerfile` in current directory:

```bash
docker build . -t myapp
```

+++

List all locally available images:

```bash
docker image ls
```

+++

Run a container using that image:

```bash
docker run -d --name myapp -p 5000:5000 myapp
```

- '-d' tells the container to run in the background |
- '--name myapp' sets the container name |
- '-p 5000:80' maps port 5000 on the host to port 80 on the container |

+++

List all containers:

```bash
docker ps -a
```

+++

List all networks:

```bash
docker network ls
```

+++

Remove the container named 'apache2':

```bash
docker stop myapp
docker rm myapp
```

+++
Read the Docker [documentation](https://docs.docker.com) for more information.
+++

---
### A SIMPLE CI PROCESS
---

### CHALLENGES PRESENTED BY CONTAINERS 

+++
Scaling of containers
+++
Scaling of nodes
+++
Scale your applications on the fly.
+++
Roll out new features seamlessly.
+++
Minimize application failure and node failure - Health Check
+++
Monitoring 
+++
Scheduling 
+++
Discovery 
+++
Load Balancing 
+++
Secrets/configuration/storage management
+++
---
### CONTAINER Orchestration

Providers include
  - Docker (swarm)
  - Kubernetes (OpenSource, RedHat OpenShift, GCE)
  - AWS ECS
  - Mesosphere Marathon 
---
### Kubernetes 
---
### Why Kubernetes ?

 - Open Source 
 - Portable: public, private, hybrid, multi-cloud
 - Self-healing: auto-placement, auto-restart, auto-replication, auto-scaling
 
 ---
 
 ### Concepts 
 

### Any questions?
