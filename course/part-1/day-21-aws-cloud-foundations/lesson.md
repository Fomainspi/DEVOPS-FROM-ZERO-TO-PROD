# Day 21 — AWS Cloud Foundations

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Understand the AWS building blocks behind modern DevOps platforms.

---

## 1. Learning objectives

You will learn:

- cloud computing fundamentals;
- Regions and Availability Zones;
- IAM;
- VPC, subnets and routing;
- EC2;
- S3;
- ECR;
- RDS;
- load balancing;
- CloudWatch;
- AWS CLI fundamentals;
- troubleshooting and cost awareness.

---

## 2. What is cloud computing?

### Definition

Cloud computing provides on-demand computing resources through services instead of requiring an organization to own and operate all physical infrastructure itself.

Resources include:

- compute;
- storage;
- databases;
- networking;
- monitoring;
- security.

### Analogy: electricity

You do not build a power station every time you need electricity.

You consume electricity as a service.

Cloud platforms provide infrastructure services in a similar model.

---

## 3. AWS

### Definition

**Amazon Web Services (AWS)** is a cloud platform offering infrastructure and managed services.

A DevOps engineer does not need to memorize every AWS service.

Start with the major building blocks:

~~~text
IAM
VPC
EC2
S3
ECR
RDS
Load Balancing
CloudWatch
EKS
~~~

The important skill is understanding how services connect.

---

## 4. Region

### Definition

An AWS **Region** is a geographic area containing AWS infrastructure.

Example:

~~~text
Region
   |
   +-- Availability Zone
   +-- Availability Zone
   +-- Availability Zone
~~~

Choose regions based on:

- latency;
- service availability;
- compliance;
- cost;
- resilience.

---

## 5. Availability Zone

### Definition

An **Availability Zone (AZ)** is an isolated location within an AWS Region.

Using multiple AZs can improve resilience.

### Analogy: multiple buildings

If your company operates from one building and that building becomes unavailable, work can stop.

Multiple buildings provide more resilience.

---

## 6. IAM

### Definition

**AWS Identity and Access Management (IAM)** controls identities and permissions for AWS resources.

Mental model:

~~~text
Identity
   |
   v
Policy
   |
   v
Allowed / denied action
~~~

Example:

> Can this CI pipeline push a container image to ECR?

IAM helps determine the answer.

---

## 7. Least privilege

Do not give:

~~~text
CI pipeline
    |
    v
Administrator
~~~

when it only needs specific ECR actions.

Better:

~~~text
CI pipeline
    |
    v
Required ECR permissions
~~~

### Analogy: master key

A room cleaner does not need the master key to every secure room.

Give only the access needed for the job.

---

## 8. VPC

### Definition

A **Virtual Private Cloud (VPC)** is a logically isolated network environment.

Think of it as your cloud network.

~~~text
VPC
 |
 +-- Public subnet
 |
 +-- Private subnet
 |
 +-- Routing
 |
 +-- Security controls
~~~

---

## 9. Subnets

### Definition

A **subnet** is an IP address range inside a VPC.

Common architecture:

~~~text
VPC
 |
 +-- Public subnets
 |     |
 |     +-- Load Balancer
 |
 +-- Private subnets
       |
       +-- Application
       +-- Database
~~~

### Analogy

VPC = city.

Subnets = districts.

Different districts can have different routing and security rules.

---

## 10. Internet Gateway and routing

A public subnet normally requires appropriate routing to an Internet Gateway.

Conceptually:

~~~text
Internet
   |
   v
Internet Gateway
   |
   v
Public subnet
~~~

Private subnets are commonly designed without direct inbound Internet access.

Architecture depends on workload requirements.

---

## 11. Security Groups

### Definition

A **Security Group** acts as a stateful virtual firewall for supported AWS resources.

Example:

~~~text
Load Balancer
  allow HTTPS
      |
      v
Application
  allow from LB
      |
      v
Database
  allow from application
~~~

This creates layered access.

---

## 12. EC2

### Definition

**Amazon EC2** provides virtual compute instances.

Think:

~~~text
EC2
 |
 +-- CPU
 +-- memory
 +-- disk
 +-- operating system
 +-- network
~~~

Use cases include:

- applications;
- build agents;
- self-managed services;
- specialized workloads.

---

## 13. S3

### Definition

**Amazon S3** is object storage.

Common uses:

- static assets;
- backups;
- logs;
- artifacts;
- data files;
- appropriate Terraform state architectures.

### Analogy: warehouse

S3 is like a managed warehouse for objects.

You store objects without managing a traditional server filesystem.

---

## 14. ECR

### Definition

**Amazon Elastic Container Registry (ECR)** stores container images.

Flow:

~~~text
Developer
   |
   v
Docker build
   |
   v
ECR
   |
   v
EKS / ECS / EC2
~~~

This connects container CI/CD with AWS.

---

## 15. RDS

### Definition

**Amazon RDS** is a managed relational database service.

Managed database services can reduce operational work around:

- provisioning;
- backups;
- maintenance;
- monitoring.

Responsibilities depend on engine and configuration.

---

## 16. Load balancing

### Definition

A load balancer distributes network traffic across available targets.

~~~text
Clients
  |
  v
Load Balancer
  |
  +-- App 1
  +-- App 2
  +-- App 3
~~~

### Analogy: supermarket checkout

A store does not want every customer waiting at one cashier while other cashiers are empty.

---

## 17. CloudWatch

### Definition

**Amazon CloudWatch** provides monitoring and observability capabilities.

Common concepts:

- metrics;
- logs;
- alarms;
- dashboards.

~~~text
Application
    |
    v
Metrics / Logs
    |
    v
CloudWatch
    |
    v
Alarm
~~~

Observability turns "something is wrong" into measurable evidence.

---

## 18. Putting the services together

A common web architecture:

~~~text
Internet
   |
   v
Load Balancer
   |
   v
Application
   |
   +------> RDS
   |
   +------> S3
   |
   +------> ECR image
   |
   v
CloudWatch
~~~

Network:

~~~text
VPC
 |
 +-- Public subnet
 |      |
 |      +-- Load Balancer
 |
 +-- Private subnet
        |
        +-- Application
        +-- Database
~~~

---

## 19. AWS CLI

Verify identity first:

~~~bash
aws sts get-caller-identity
~~~

This answers:

> Which AWS identity am I using?

Then inspect resources.

Example:

~~~bash
aws s3 ls
~~~

Never start destructive work before confirming account, identity and region.

---

## 20. AWS troubleshooting

Use this order:

~~~text
Identity
  |
Region
  |
Network
  |
Security
  |
Resource
  |
Logs / Metrics
~~~

Example: application cannot reach RDS.

Check:

1. VPC;
2. subnet routing;
3. Security Groups;
4. database endpoint;
5. database availability;
6. credentials;
7. application logs.

Do not assume the database is broken just because the application cannot connect.

---

## 21. Cost awareness

Cloud resources can cost money.

Before creating resources:

- understand pricing;
- use small lab resources;
- tag resources;
- set budgets/alerts where appropriate;
- delete unused resources;
- document cleanup.

### FOMA rule

> **Never create paid cloud infrastructure without knowing how you will monitor and remove it.**

---

## 22. Hands-on lab

Using an AWS lab account:

1. verify identity;
2. choose a region;
3. inspect S3;
4. inspect ECR;
5. inspect VPC and subnets;
6. inspect Security Groups;
7. inspect CloudWatch;
8. draw the architecture.

Start with read-only operations.

Create resources only after cost and cleanup are understood.

---

## 23. Production best practices

- Use least-privilege IAM.
- Prefer roles/federated identities over long-lived keys.
- Use multiple AZs where resilience requires it.
- Keep databases private where appropriate.
- Use encryption.
- Monitor resources.
- Tag resources.
- Control costs.
- Automate infrastructure with Terraform.
- Minimize manual production changes.

---

## 24. Knowledge check

1. What is cloud computing?
2. What is a Region?
3. What is an Availability Zone?
4. What is IAM?
5. What is a VPC?
6. What is a subnet?
7. What is EC2?
8. What is S3?
9. What is ECR?
10. What is RDS?
11. What does a load balancer do?
12. What does CloudWatch provide?
13. Why use least privilege?
14. Why verify AWS identity?
15. Why is cost awareness part of DevOps?

### Answers

1. On-demand consumption of infrastructure/services.
2. A geographic AWS infrastructure area.
3. An isolated location within a Region.
4. Identity and access control.
5. An isolated cloud network.
6. An IP range within a VPC.
7. Virtual compute.
8. Object storage.
9. Container image registry.
10. Managed relational database service.
11. Distributes traffic.
12. Metrics, logs, alarms and dashboards.
13. To reduce unnecessary access and risk.
14. To avoid modifying the wrong account/resources.
15. Cloud infrastructure creates usage-based costs.

---

## 25. Day 21 challenge

Design:

~~~text
Internet
   |
Load Balancer
   |
Application
   |
 +--- RDS
 |
 +--- S3
 |
 +--- ECR
 |
CloudWatch
~~~

Place application and database resources in an appropriate VPC/subnet design.

Explain:

- identity;
- networking;
- security;
- compute;
- storage;
- observability;
- cost controls.

### FOMA takeaway

> **AWS becomes easier when you stop memorizing service names and understand how identity, network, compute, storage and observability work together.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
