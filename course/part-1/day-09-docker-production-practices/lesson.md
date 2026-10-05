# Day 09 — Docker Production Practices

> **FOMA — DEVOPS FROM ZERO TO PRODUCTION**  
> Build • Practice • Secure • Operate

## 1. Mission

Day 8 taught you to containerize an application. Day 9 asks a production question: **Can we run it efficiently, securely, reproducibly, and troubleshoot it?**

### Objectives
- Understand Docker architecture.
- Build and run images predictably.
- Use volumes and networks correctly.
- Write production-minded Dockerfiles.
- Optimize images with multi-stage builds.
- Apply basic container security.
- Push and pull images from a registry.
- Diagnose startup, networking, storage, and image problems.

## 2. Docker architecture

~~~text
Docker CLI → Docker Engine → Images → Containers
                         ↘ Networks / Volumes
Images ↔ Registry
~~~

**CLI** sends commands. **Engine/daemon** builds and manages resources. An **image** is an immutable template. A **container** is a running instance. A **registry** distributes images.

### Image vs container

Think **image = template**, **container = running instance**. Many containers can be created from one image.

## 3. Essential commands

~~~bash
docker version
docker info
docker pull nginx
docker images
docker run -d --name foma-nginx -p 8080:80 nginx
docker ps
docker ps -a
docker logs foma-nginx
docker exec -it foma-nginx sh
docker stop foma-nginx
docker rm foma-nginx
~~~

Inspect deeply:

~~~bash
docker image inspect nginx
docker history nginx
docker inspect foma-nginx
~~~

## 4. Production Dockerfile

~~~dockerfile
FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN useradd --create-home --shell /usr/sbin/nologin appuser
USER appuser

EXPOSE 5000
CMD ["python", "app.py"]
~~~

Docker caches layers. Copy dependency files before application code when practical so dependency layers can be reused.

### .dockerignore

~~~text
.git
.github
.env
.venv
__pycache__
*.pyc
node_modules
~~~

Do not put secrets into the image and assume .dockerignore protects them. Secrets should never be copied into image layers.

## 5. Build and run

~~~bash
docker build -t foma-python-app:1.0 .
docker run -d --name foma-app -p 5000:5000 foma-python-app:1.0
docker logs -f foma-app
curl http://localhost:5000/health
~~~

Use docker exec for diagnosis, not as the normal way to operate application processes.

## 6. Volumes and persistence

Container writable storage is disposable. Use a volume when data must survive container replacement.

~~~bash
docker volume create foma-data
docker volume ls
docker volume inspect foma-data
~~~

Example:

~~~bash
docker run -d --name postgres   -v foma-data:/var/lib/postgresql/data   -e POSTGRES_PASSWORD=change-me   postgres:16
~~~

Choose a persistence strategy deliberately; do not treat a container filesystem as a database.

## 7. Networking

~~~bash
docker network create foma-net
docker run -d --name backend --network foma-net nginx
docker run -d --name client --network foma-net alpine sleep 3600
docker exec client wget -qO- http://backend
~~~

Containers on the same user-defined network can discover each other by name.

~~~text
host:8080 → container:80
~~~

The host port is published; the container port is where the application listens.

## 8. Docker Compose

~~~yaml
services:
  web:
    build: .
    ports:
      - "5000:5000"
    networks: [foma-net]
  redis:
    image: redis:7-alpine
    networks: [foma-net]

networks:
  foma-net:
~~~

~~~bash
docker compose up -d --build
docker compose ps
docker compose logs -f
docker compose down
~~~

Compose is excellent for local development, integration tests, and reproducible labs. Kubernetes becomes useful when cluster orchestration, scheduling, service discovery, scaling, and self-healing are required.

## 9. Multi-stage builds

~~~dockerfile
FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .
RUN useradd --create-home appuser
USER appuser
CMD ["python", "app.py"]
~~~

Benefits: smaller final images, fewer packages, smaller attack surface, and faster transfer.

## 10. Image optimization

Prefer:
- trusted, maintainable base images;
- small runtime images where appropriate;
- multi-stage builds;
- useful layer ordering;
- .dockerignore;
- no package caches in the final image;
- no build tools in the runtime stage;
- explicit version tags.

Inspect:

~~~bash
docker image ls
docker history foma-python-app:1.0
docker image inspect foma-python-app:1.0
~~~

**Small is not automatically secure.** Maintainability and vulnerability response matter too.

## 11. Security

Run as a non-root user:

~~~dockerfile
USER appuser
~~~

With Trivy installed:

~~~bash
trivy image foma-python-app:1.0
~~~

Avoid casually using privileged mode, mounting sensitive host paths, or granting unnecessary capabilities.

## 12. Registry workflow

~~~bash
docker login
docker tag foma-python-app:1.0 YOUR_USER/foma-python-app:1.0
docker push YOUR_USER/foma-python-app:1.0
docker pull YOUR_USER/foma-python-app:1.0
~~~

Use traceable tags such as foma-web:1.4.2 or foma-web:git-a13f9c2. Do not rely on latest as your only production reference.

## 13. Troubleshooting

### Container exits
~~~bash
docker ps -a
docker logs <container>
docker inspect <container>
~~~

Check the command, environment, permissions, and exit code.

### Port conflict
~~~bash
docker ps
ss -ltnp
~~~

### Network problem
~~~bash
docker network ls
docker network inspect foma-net
docker exec <container> getent hosts <service>
~~~

### Permission problem
~~~bash
docker exec <container> id
docker exec <container> ls -ld /path
~~~

### Image too large
~~~bash
docker history <image>
~~~

Improve .dockerignore, remove unnecessary packages, and consider multi-stage builds.

## 14. Hands-on practice

Using the lab directory:
1. Build the Flask image.
2. Run it on port 5000.
3. Verify /health.
4. Add a named volume.
5. Create a custom network.
6. Run a second container on that network.
7. Convert the setup to Compose.
8. Use a multi-stage pattern.
9. Run as non-root.
10. Scan the image if Trivy is available.
11. Tag it with a release version.
12. Push it to a registry you control.

### Knowledge check
1. Image vs container?
2. Why copy dependency files before source code?
3. What does .dockerignore do?
4. Why use named volumes?
5. What does -p 8080:80 mean?
6. Why use a user-defined network?
7. What does multi-stage building remove?
8. Why avoid root?
9. Why use traceable tags?
10. What should you inspect when a container exits?

## 15. Production checklist

- [ ] Trusted and maintainable base image
- [ ] Reproducible Dockerfile
- [ ] Useful .dockerignore
- [ ] No secrets in image layers
- [ ] Non-root runtime user
- [ ] Health endpoint/check where appropriate
- [ ] Logs available through stdout/stderr
- [ ] Persistent data externalized
- [ ] Network exposure intentional
- [ ] Image scanned
- [ ] Versioned image tag
- [ ] Registry access protected
- [ ] Rollback image identified

> **FOMA principle:** A container that works on a laptop is only the beginning. Production readiness means reproducibility, security, observability, and controlled change.

**Next:** Day 10 — Kubernetes Fundamentals

**William Foma | Foundation of Mastering Automation | https://foma.life**
