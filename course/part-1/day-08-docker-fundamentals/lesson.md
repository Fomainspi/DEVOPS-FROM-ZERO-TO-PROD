# DAY 8 — DOCKER FUNDAMENTALS

> Foundation of Mastering Automation (FOMA)  
> Course: DevOps from Zero to Production  
> Trainer: William Foma

## 1. Objectives

By the end of Day 8 you can:

- explain images, containers and registries
- build and run Docker images
- manage containers and logs
- map ports
- persist data with volumes
- connect services with Docker networks
- run multi-container applications with Compose
- push and pull images
- apply image-security practices
- troubleshoot container failures

## 2. Docker mental model

~~~text
Application + dependencies
          ↓
       IMAGE
          ↓
      CONTAINER
          ↓
       runtime
~~~

An image is a packaged template. A container is a running instance of an image. A registry stores and distributes images.

## 3. Verify Docker

~~~bash
docker version
docker info
docker run --rm hello-world
~~~

## 4. Essential commands

~~~bash
docker pull nginx
docker run -d --name foma-nginx -p 8080:80 nginx
docker ps
docker ps -a
docker inspect foma-nginx
docker logs foma-nginx
docker logs -f foma-nginx
docker stop foma-nginx
docker rm foma-nginx
docker rmi nginx
~~~

## 5. Images and containers

~~~text
                IMAGE
             nginx:stable
                  │
        ┌─────────┴─────────┐
        ↓                   ↓
 container A          container B
 port 8080            port 8081
~~~

One image can create multiple containers.

## 6. Dockerfile

A Dockerfile is a set of build instructions.

~~~dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
~~~

Core instructions:

| Instruction | Meaning |
|---|---|
| FROM | base image |
| WORKDIR | working directory |
| COPY | copy files |
| RUN | build-time command |
| ENV | environment variable |
| EXPOSE | document listening port |
| CMD | default runtime command |
| ENTRYPOINT | executable entrypoint |

Docker's Dockerfile documentation describes these instructions and the conventional Dockerfile filename. citeturn0search6

## 7. Build and run

~~~bash
docker build -t foma-python-app:1.0 .
docker images
docker image inspect foma-python-app:1.0

docker run -d   --name foma-app   -p 5000:5000   foma-python-app:1.0

curl http://localhost:5000/
~~~

## 8. Port mapping

~~~text
HOST:5000  ─────────→  CONTAINER:5000
~~~

The first number is the host port.

If 5000 is occupied:

~~~bash
docker run -p 5001:5000 foma-python-app:1.0
~~~

## 9. Volumes

Container writable storage is not a replacement for persistent storage.

Create a volume:

~~~bash
docker volume create foma-data
docker volume ls
docker volume inspect foma-data
~~~

Example database:

~~~bash
docker run -d   --name foma-db   -v foma-data:/var/lib/postgresql/data   postgres:16
~~~

## 10. Networks

Create a network:

~~~bash
docker network create foma-net
~~~

Run services on it:

~~~bash
docker run -d --name foma-db --network foma-net postgres:16
docker run -d --name foma-app --network foma-net foma-python-app:1.0
~~~

Use service/container names for communication on a user-defined network. Inside a container, localhost means that same container, not another service.

## 11. Docker Compose

Compose describes multi-container applications.

~~~yaml
services:
  app:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - db

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: dev-only-password
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
~~~

Start:

~~~bash
docker compose up -d --build
~~~

Inspect:

~~~bash
docker compose ps
docker compose logs -f
~~~

Stop:

~~~bash
docker compose down
~~~

Docker's current Compose guidance covers services, health checks, named volumes and inspecting/debugging running stacks. citeturn0search4

## 12. Registry workflow

~~~bash
docker login
docker tag foma-python-app:1.0 USERNAME/foma-python-app:1.0
docker push USERNAME/foma-python-app:1.0
docker pull USERNAME/foma-python-app:1.0
~~~

Production environments often use private registries such as cloud container registries.

## 13. Image security and optimization

Good practices:

- use trusted base images
- choose an appropriately small image
- use .dockerignore
- avoid unnecessary packages
- pin important dependencies
- scan images
- do not bake secrets into images
- use meaningful immutable release tags
- avoid running as root when unnecessary
- use multi-stage builds where useful

Docker recommends trusted/minimal bases and multi-stage builds when they reduce the final runtime image. citeturn0search2

Typical production pattern:

~~~text
Builder stage
   ↓ build/test
Final runtime stage
   ↓ only runtime content
Production container
~~~

## 14. Troubleshooting

### Container exits

~~~bash
docker ps -a
docker logs CONTAINER
~~~

The container normally stops when its main process exits.

### Port conflict

~~~bash
ss -tulpn | grep 5000
docker ps
~~~

Change the host port or stop the conflicting process.

### Image not found

~~~bash
docker images
docker pull IMAGE
~~~

### Permission denied

Determine whether the problem is Docker daemon access, filesystem ownership, mounted volume permissions or application user permissions.

### Container-to-container connection fails

~~~bash
docker network ls
docker network inspect foma-net
docker exec -it foma-app sh
~~~

Confirm both services are on the expected network and that the application uses the service name rather than localhost.

## 15. Hands-on practice

1. Run Nginx on host port 8080.
2. Inspect its logs.
3. Build a Python image.
4. Run the image.
5. Map a port.
6. Create a named volume.
7. Create a user-defined network.
8. Build an application + PostgreSQL Compose stack.
9. Push the image to a registry.
10. Intentionally break a container and troubleshoot it.

## 16. Knowledge check

1. What is an image?
2. What is a container?
3. What is a registry?
4. What does docker build do?
5. What does -p 5000:5000 mean?
6. Why use volumes?
7. Why use user-defined networks?
8. What does Compose solve?
9. Why use .dockerignore?
10. Why avoid secrets in images?
11. What do you inspect when a container exits?
12. Why use multi-stage builds?

### Answers

1. An immutable template for creating containers.
2. A running instance of an image.
3. A store/distribution system for images.
4. Builds an image from a Dockerfile and build context.
5. Maps host port 5000 to container port 5000.
6. To persist data beyond container lifecycle.
7. To provide controlled service communication.
8. Declarative multi-container management.
9. To reduce context and exclude unwanted files.
10. Image layers can expose them.
11. docker ps -a and docker logs.
12. To keep build tooling out of the final runtime image.

## 17. Day 8 checklist

- [ ] Container launched
- [ ] Logs inspected
- [ ] Image built
- [ ] Port mapped
- [ ] Volume used
- [ ] Network created
- [ ] Compose used
- [ ] Image pushed/pulled
- [ ] Security practices applied
- [ ] Failure troubleshot

**FOMA — Foundation of Mastering Automation**  
Learn • Practice • Build • Advance  
https://foma.life
