DevOps Take-Home: Java API on AWS Fargate
Overview

## Project Structure

```text
devops-take-home/

├── Docker                  #Docker folder
    ├──Dockerfile           # Multi-stage build for Java/NewRelic
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
<img width="1500" height="246" alt="Screenshot from 2026-01-28 09-00-14" src="https://github.com/user-attachments/assets/d5d2a9a7-3666-4922-b56e-eeafa66cfa10" />

5. Monitoring & Observability setup
New Relic Setup
<img width="1849" height="961" alt="Screenshot from 2026-01-28 10-29-13" src="https://github.com/user-attachments/assets/d595fef7-9848-4ba1-9a1e-baa87f4c46dc" />
<img width="1849" height="961" alt="Screenshot from 2026-01-28 10-28-48" src="https://github.com/user-attachments/assets/aa943c7f-2179-4616-aa2f-64b891611e55" />
<img width="1859" height="749" alt="Screenshot from 2026-01-28 10-28-31" src="https://github.com/user-attachments/assets/5acd7a1c-f3cc-4983-a753-76410c656fea" />
<img width="1228" height="961" alt="Screenshot from 2026-01-28 17-01-44" src="https://github.com/user-attachments/assets/eeab1528-255b-4459-925b-c46b8c4cc504" />
<img width="620" height="961" alt="Screenshot from 2026-01-28 17-01-27" src="https://github.com/user-attachments/assets/23a02a82-9c2a-48ba-b829-1029a2fec99c" />
<img width="439" height="961" alt="Screenshot from 2026-01-28 17-01-15" src="https://github.com/user-attachments/assets/0a3780d7-ef0d-4bf4-914b-91203cd22595" />

<img width="458" height="961" alt="Screenshot from 2026-01-28 17-04-41" src="https://github.com/user-attachments/assets/d0f627c3-fe78-4895-90f0-922392c9352f" />
<img width="1538" height="961" alt="Screenshot from 2026-01-28 17-04-32" src="https://github.com/user-attachments/assets/83829f4f-ee39-4b42-a1e4-a0c2f90dc1d5" />
<img width="908" height="961" alt="Screenshot from 2026-01-28 17-04-20" src="https://github.com/user-attachments/assets/fa32c181-aeb3-496e-971d-2a09ff814bf7" />
<img width="908" height="961" alt="Screenshot from 2026-01-28 17-04-12" src="https://github.com/user-attachments/assets/c8423a52-7e49-44d1-b901-1e6ebcd41e1b" />
<img width="908" height="961" alt="Screenshot from 2026-01-28 17-02-18" src="https://github.com/user-attachments/assets/ef88dc7d-56ae-4168-8099-79324433d64e" />
<img width="525" height="961" alt="Screenshot from 2026-01-28 17-02-06" src="https://github.com/user-attachments/assets/8cbb4b10-a57f-4fa5-98e8-edeba5bb4d1b" />
<img width="1699" height="961" alt="Screenshot from 2026-01-28 17-05-46" src="https://github.com/user-attachments/assets/bdf83756-e7e1-48ba-bb8c-7f2b3a044b00" />
<img width="1699" height="961" alt="Screenshot from 2026-01-28 17-05-30" src="https://github.com/user-attachments/assets/a3035e2c-3360-4608-82d8-902073a413ec" />


<img width="1377" height="689" alt="Screenshot from 2026-01-28 17-06-47" src="https://github.com/user-attachments/assets/9eb55e29-ca80-4382-964f-c49f1b68faab" />


![alt text](<Screenshot from 2026-01-28 17-06-47.png>)

Logging
Logs are streamed to CloudWatch under the group /ecs/java-app.

Retention: 7 days (configured in terraform/modules/logs).

SUCCESS
<img width="1364" height="667" alt="Screenshot from 2026-01-28 02-42-40" src="https://github.com/user-attachments/assets/9ad5fb3d-d8fe-4f24-9ed3-84f07019c6d6" />
<img width="1701" height="624" alt="Screenshot from 2026-01-28 09-16-21" src="https://github.com/user-attachments/assets/4784a73d-4a69-4798-bd68-9e225ac7f20c" />
<img width="1649" height="302" alt="Screenshot from 2026-01-28 09-16-07" src="https://github.com/user-attachments/assets/29c17c2e-e2f4-442a-b776-b026d84f2643" />
<img width="1500" height="246" alt="Screenshot from 2026-01-28 09-01-14" src="https://github.com/user-attachments/assets/f2038cee-4b87-4011-bf5f-fc9d4da59ce2" />



6. Troubleshooting
Health Checks failing? Ensure the /health endpoint in Restapi.java returns a 200 OK and matches the ALB health check path.
