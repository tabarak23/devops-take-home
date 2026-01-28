DevOps Take-Home: Java API on AWS Fargate
Overview

## Project Structure

```text
devops-take-home/
├── Dockerfile              # Multi-stage build for Java/NewRelic
├── pom.xml                 # Maven project dependencies/config
├── newrelic/               # NR Agent binaries and config
│   ├── newrelic.jar        # The agent library for JVM
│   └── newrelic.yml        # Agent settings and app name
├── src/                    # Java Spring Boot source code
│   └── main/java/...       # Health check API controller logic
├── environments/           # Environment-specific TF configurations
│   ├── dev/                # Development variables and state files
│   ├── staging/            # Staging environment config files
│   └── prod/               # Production environment config files
├── terraform/              # Reusable Infrastructure modules
│   └── modules/
│       ├── vpc/            # Networking: Subnets, NAT, IGW
│       ├── alb/            # Load Balancer and target groups
│       ├── ecs/            # Cluster and Fargate task definitions
│       ├── ecr/            # Private Docker registry for images
│       ├── iam/            # Task and Execution security roles
│       ├── logs/           # CloudWatch Log groups/retention
│       └── autoscaling/    # CPU/Memory based scaling policies
└── .github/workflows/      # CI/CD automation pipelines (YAML)
This repository contains the Infrastructure as Code (Terraform), Containerization (Docker), and CI/CD (GitHub Actions) logic to deploy a Spring Boot Java application to AWS Fargate.

Infrastructure Components
VPC: Custom VPC with Public (ALB) and Private (ECS Tasks) subnets across 2 AZs.

Compute: AWS ECS Cluster using the Fargate launch type for serverless execution.

Networking: Application Load Balancer (ALB) routing traffic to ECS services.

Storage: ECR for Docker image management.

Observability: CloudWatch Logs for persistence and New Relic APM for application performance.

1. Prerequisites
AWS CLI configured with appropriate permissions.

Terraform (v1.0+) installed.

New Relic Account (License Key required).

GitHub Repository with the following secrets configured:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

NEW_RELIC_LICENSE_KEY

2. Infrastructure (Terraform)
The infrastructure is modularized and supports multiple environments located in ./environments.

How to Run
Bash

cd environments/dev
terraform init
terraform plan
terraform apply
Key Security Decisions
Least Privilege: IAM roles are split between Task Execution (pulling images/logs) and Task Role (app-specific permissions).

Network Isolation: ECS tasks reside in private subnets. The Security Group only allows ingress from the ALB's Security Group on port 8080.

3. Dockerization & New Relic
We use a multi-stage build to keep the production image slim and secure.

Stage 1 (Build): Uses Maven to compile the .jar.

Stage 2 (Runtime): Uses Amazon Corretto (Alpine-based) and includes the New Relic Java Agent.

User: Runs as a non-root user appuser for security.

New Relic Integration: The agent is included in the ./newrelic folder and passed via the JAVA_OPTS environment variable in the ECS Task Definition: -javaagent:/usr/local/newrelic/newrelic.jar

4. CI/CD Pipeline Flow
The GitHub Actions workflow (.github/workflows/deploy.yml) follows this logic:

PR to Main: Triggers Maven tests and Docker build (no push).

Push to Main:

Builds and tags the image with the Git SHA.

Pushes image to ECR.

Updates the ECS Task Definition and triggers a rolling deployment.

Verifies health via the ALB endpoint.

5. Monitoring & Observability
New Relic Setup
APM: View JVM metrics, transaction traces, and error rates in the New Relic UI.

Dashboards: Created a custom dashboard tracking Request Latency vs. CPU Usage.

Alerting: Configured NRQL alerts for:

CPU > 80%

Heap Memory > 80%

Apdex score < 0.5

Logging
Logs are streamed to CloudWatch under the group /ecs/java-app.

Retention: 7 days (configured in terraform/modules/logs).

6. Troubleshooting
Health Checks failing? Ensure the /health endpoint in Restapi.java returns a 200 OK and matches the ALB health check path.

Terraform State: State is currently local for this exercise. In a production environment, use an S3 backend with DynamoDB locking.
