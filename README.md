# Expense Dev Infrastructure

Automated three-tier AWS development infrastructure provisioned with Terraform, decoupled through AWS Systems Manager (SSM) Parameter Store, and configured via Ansible Pull.

---

## Key Features

- **Layered Infrastructure as Code**: Deconstructs AWS infrastructure into 9 isolated, manageable Terraform root modules (`00` to `80`) to minimize blast radius and support independent tier lifecycles.
- **Service Discovery via Parameter Store**: Shares dynamic configuration (VPC IDs, subnet IDs, security groups, listener ARNs) across layers through AWS SSM Parameter Store instead of tightly coupled remote state lookups.
- **Automated AMI Baking with Ansible Pull**: Orchestrates an immutable image pipeline within Terraform using temporary EC2 instances and `ansible-pull` to produce versioned AMIs for Auto Scaling Groups.
- **Network Segmentation**: Isolates workloads across public, private, and database subnets spanning two Availability Zones in `us-east-1` with chained security group firewall rules.
- **Secure Management & Private Routing**: Uses an OpenVPN Access Server and Bastion Jump Host for operational connectivity and Terraform remote provisioning into private subnets.
- **Dual Load Balancing & Auto Scaling**: Routes external web traffic through an internet-facing Application Load Balancer and internal API traffic through a private ALB, backed by Auto Scaling Groups with health checking.
- **Orchestrated Lifecycle Automation**: Includes automated shell scripts ([apply.sh](./apply.sh) and [destroy.sh](./destroy.sh)) to manage forward and reverse dependency chains across all modules.

---

## Architecture & Request Flow

The infrastructure implements a decoupled three-tier architecture distributed across public, private, and database subnets spanning two Availability Zones in the `us-east-1` region.

### Request Flow (User to Database)

1. **Client Request**: End users access the application via the public-facing **Web Application Load Balancer** (`expense-dev-web-alb`) on port 80 HTTP.
2. **Frontend Routing**: The Web ALB matches rule `/*` (priority 10) and forwards traffic to the `expense-dev-frontend` target group, distributing requests across Nginx instances in the Frontend Auto Scaling Group.
3. **Internal API Routing**: Frontend Nginx reverse proxies API calls (`/backend.app/*`) to the private **Internal App Load Balancer** (`expense-dev-alb`) listening on port 80 in the private subnets.
4. **Backend Processing**: The internal ALB matches `/backend.app` and `/backend.app/*` (priority 10) and forwards traffic to the `expense-dev-backend` target group on port 8080 HTTP (Node.js application).
5. **Database Persistence**: Backend instances query the **Amazon RDS MySQL** database (`transactions` DB) on port 3306 in the isolated database subnets.
6. **Remote Administration**: Operators connect through the **OpenVPN Access Server** for direct private subnet routing or through the **Bastion Host** for database troubleshooting.

### Network Tiers & Subnet Allocation

- **Public Subnets (`10.0.1.0/24`, `10.0.2.0/24`)**:
  Connected directly to the AWS Internet Gateway. Hosts the **Public Web Load Balancer**, **Frontend Auto Scaling Group**, **Bastion Jump Host**, and **OpenVPN Access Server**.
- **Private Subnets (`10.0.11.0/24`, `10.0.12.0/24`)**:
  Isolated from direct internet ingress (no public IPs). Hosts the **Internal App Load Balancer** and **Backend Auto Scaling Group**.
- **Database Subnets (`10.0.21.0/24`, `10.0.22.0/24`)**:
  Dedicated database tier with strictly no internet routing. Hosts the **Amazon RDS MySQL** database instance, accessible only on port 3306 by backend application servers, Bastion, and OpenVPN.
- **Supporting Services**:
  - **AWS SSM Parameter Store**: Acts as a decoupled central service registry sharing VPC, subnet, and security group IDs across modules.
  - **Remote State Backend**: Amazon S3 bucket (`jithesh-tf-remote-state-expense-dev`) with DynamoDB state locking (`jithesh-state-locking-expense-dev`).

---

## Technology Stack

| Technology | Category | Description |
|---|---|---|
| **AWS** | Cloud Provider | VPC, EC2, ALB, Auto Scaling, RDS, SSM, S3, DynamoDB |
| **Terraform** | Infrastructure as Code | Modular infrastructure provisioning |
| **Ansible** | Configuration Management | Configuration using `ansible-pull` |
| **RHEL 9** | Operating System | Base operating system for compute nodes |
| **OpenVPN Access Server** | Remote Access | VPN access to private network resources |
| **Amazon RDS MySQL** | Database | Managed MySQL database |
| **Nginx** | Web Server / Proxy | Serves the frontend and proxies API requests |
| **Bash** | Scripting | Deployment and cleanup automation |
| **Git / GitHub** | Version Control | Source control and project hosting |

---

## Infrastructure Layers and Responsibilities

The codebase is structured into 9 isolated root modules applied in sequential order:

| Layer | Component | Directory | Responsibility |
|---|---|---|---|
| 00 | VPC & Networking | [00-vpc](./00-vpc/) | Multi-AZ VPC with public, private, and database subnets |
| 10 | Security Groups | [10-sg](./10-sg/) | Inter-tier security group firewall rules |
| 20 | Bastion Host | [20-bastion](./20-bastion/) | Public EC2 jump host for administrative SSH access |
| 30 | OpenVPN Server | [30-vpn](./30-vpn/) | SSL/TLS VPN gateway for direct access to private subnets |
| 40 | RDS Database | [40-rds](./40-rds/) | Managed Amazon RDS MySQL database in private database subnets |
| 50 | Internal ALB | [50-alb](./50-alb/) | Private Application Load Balancer routing internal API traffic |
| 60 | Backend ASG | [60-backend](./60-backend/) | Node.js backend Auto Scaling Group with custom baked AMI |
| 70 | Public Web ALB | [70-webalb](./70-webalb/) | Internet-facing Application Load Balancer for web ingress |
| 80 | Frontend ASG | [80-frontend](./80-frontend/) | Nginx frontend Auto Scaling Group with custom baked AMI |

---

## Repository Structure

```text
terraform-expense-dev-infrastructure/
├── apply.sh                     # Automated sequential deployment script (00 -> 80)
├── destroy.sh                   # Automated sequential teardown script (80 -> 00)
├── README.md                    # Project documentation
├── 00-vpc/                      # VPC, subnets, peering, DB subnet group
├── 10-sg/                       # Security groups and ingress firewall rules
├── 20-bastion/                  # Bastion EC2 jump host
├── 30-vpn/                      # OpenVPN Access Server and key pair
├── 40-rds/                      # Amazon RDS MySQL 8.0 instance
├── 50-alb/                      # Internal Application Load Balancer
├── 60-backend/                  # Backend instance bootstrap, AMI bake, ASG
├── 70-webalb/                   # Internet-facing Web Application Load Balancer
└── 80-frontend/                 # Frontend instance bootstrap, AMI bake, ASG
```

---

## Deployment Prerequisites

Before running the deployment scripts:

1. **Terraform**: Install Terraform CLI (`v1.5.0` or higher).
2. **AWS CLI & Credentials**: Configure AWS credentials with administrative access to VPC, EC2, RDS, Auto Scaling, ELBv2, SSM, S3, and DynamoDB:
   ```bash
   aws sts get-caller-identity
   ```
3. **Remote State Resources**: Create the S3 bucket and DynamoDB table used by the backend blocks in `us-east-1`:
   - S3 Bucket: `jithesh-tf-remote-state-expense-dev`
   - DynamoDB Table: `jithesh-state-locking-expense-dev` (Partition key: `LockID` of type `String`)
4. **Base AMI Access**: Verify access to AMI `Redhat-9-DevOps-Practice` owned by account `973714476881` in `us-east-1`.
5. **Configuration Placeholders**:
   - **SSH Public Key**: In `30-vpn/vpn.tf`, update the `public_key` file path to point to a valid local SSH public key (e.g., `~/.ssh/id_rsa.pub`).
   - **Operator IP**: In `10-sg/sg.tf`, update the CIDR in `aws_security_group_rule.bastion_public` to your current public IP address (`<YOUR_IP>/32`).

---

## Deployment Instructions

### Automated Deployment

The [apply.sh](./apply.sh) script applies all directories sequentially:

```bash
git clone https://github.com/jitheshl/terraform-expense-dev-infrastructure.git
cd terraform-expense-dev-infrastructure
chmod +x apply.sh
./apply.sh
```

> [!IMPORTANT]
> **Operational Requirement**: Because `60-backend` uses SSH to connect to a private IP (`10.0.11.x`), running `apply.sh` from an external workstation will fail unless you are connected to the VPC via OpenVPN. Follow the staged manual deployment below when running from an external workstation.

---

### Staged Manual Deployment

#### Stage 1: Network, Security & Remote Access
```bash
cd 00-vpc && terraform init && terraform apply -auto-approve && cd ..
cd 10-sg && terraform init && terraform apply -auto-approve && cd ..
cd 20-bastion && terraform init && terraform apply -auto-approve && cd ..
cd 30-vpn && terraform init && terraform apply -auto-approve && cd ..
```

#### Stage 2: Connect to OpenVPN
1. Retrieve the OpenVPN public IP from the `30-vpn` output or AWS Console.
2. Navigate to `https://<VPN_PUBLIC_IP>:943/admin` and sign in.
3. Download the client configuration (`.ovpn`) profile.
4. Connect your OpenVPN client to join the `10.0.0.0/16` network.

#### Stage 3: Database, Internal ALB & Backend ASG
```bash
# Ensure OpenVPN client is connected before running 60-backend
cd 40-rds && terraform init && terraform apply -auto-approve && cd ..
cd 50-alb && terraform init && terraform apply -auto-approve && cd ..
cd 60-backend && terraform init && terraform apply -auto-approve && cd ..
```

#### Stage 4: Public Load Balancer & Frontend ASG
```bash
cd 70-webalb && terraform init && terraform apply -auto-approve && cd ..
cd 80-frontend && terraform init && terraform apply -auto-approve && cd ..
```

---

## Provisioning & AMI Baking Workflow

Modules `60-backend` and `80-frontend` build custom AMIs directly within the Terraform execution lifecycle:

1. **Launch Temporary Instance**: Terraform launches a base Red Hat 9 instance in the target subnet.
2. **Execute Ansible Pull**: Terraform connects via SSH, uploads the bootstrap script, and runs `ansible-pull` from `expense-ansible-roles-tf` to install packages and configure systemd services.
3. **Stop Instance**: Terraform changes instance state to `stopped` to ensure disk consistency.
4. **Bake Custom AMI**: Terraform creates an AMI snapshot from the stopped instance.
5. **Terminate Bootstrap Instance**: Terraform terminates the temporary EC2 instance using the AWS CLI.
6. **Deploy Auto Scaling Group**: A Launch Template references the new AMI, and the ASG provisions production-ready application nodes.

---

## How to Verify the Deployment

### 1. Discover Public Web ALB DNS
The `70-webalb` module does not define an explicit output file. Query the public DNS name using the AWS CLI:

```bash
WEB_ALB_DNS=$(aws elbv2 describe-load-balancers \
  --names expense-dev-web-alb \
  --region us-east-1 \
  --query "LoadBalancers[0].DNSName" \
  --output text)

echo "Web Application URL: http://${WEB_ALB_DNS}"
```

### 2. Verify Application Endpoints
- **Frontend Web Page**:
  ```bash
  curl -I "http://${WEB_ALB_DNS}/"
  ```
  Expected output: HTTP `200 OK` served by Nginx.

- **Backend Health Endpoint** (From within the VPC / via OpenVPN):
  ```bash
  curl -I "http://<INTERNAL_ALB_DNS>/health"
  ```
  Expected output: HTTP `200 OK` (evaluated by target group matcher `200-299`).

### 3. Check Target Group Health
```bash
# Frontend Target Group Health
FRONTEND_TG_ARN=$(aws elbv2 describe-target-groups --names expense-dev-frontend --query "TargetGroups[0].TargetGroupArn" --output text --region us-east-1)
aws elbv2 describe-target-health --target-group-arn "$FRONTEND_TG_ARN" --region us-east-1

# Backend Target Group Health
BACKEND_TG_ARN=$(aws elbv2 describe-target-groups --names expense-dev-backend --query "TargetGroups[0].TargetGroupArn" --output text --region us-east-1)
aws elbv2 describe-target-health --target-group-arn "$BACKEND_TG_ARN" --region us-east-1
```

> [!NOTE]
> In `60-backend/output.tf` and `80-frontend/output.tf`, the outputs reference temporary instances that are terminated after AMI baking. Verify active compute through the Auto Scaling Groups rather than these outputs.

---

## Troubleshooting

| Issue | Root Cause | Solution |
|---|---|---|
| SSH timeout (10.0.11.x:22) in `60-backend` | Workstation cannot reach private subnet `10.0.11.0/24` | Connect to OpenVPN (`30-vpn`) before running `60-backend` |
| SSH timeout to Bastion host | Operator public IP does not match security group rule | Update `aws_security_group_rule.bastion_public` in `10-sg/sg.tf` |
| Key file missing in `30-vpn` | Hardcoded public key path does not exist on machine | Update line 3 in `30-vpn/vpn.tf` to point to a valid public key |
| Target Group unhealthy on port 8080 | Backend app service is inactive or failing `/health` check | Connect via VPN and inspect `systemctl status backend` |
| Target Group unhealthy on port 80 | Frontend Nginx service is stopped or failing `/` check | Connect to frontend instance and verify `systemctl status nginx` |
| DynamoDB State Lock error | Stale lock from an interrupted Terraform run | Release lock: `terraform force-unlock <LOCK_ID>` |

---

## Cleanup Instructions

Destroy all managed infrastructure in **strict reverse dependency order** to avoid dependency errors.

### Automated Cleanup
```bash
chmod +x destroy.sh
./destroy.sh
```

### Manual Teardown Order
```bash
cd 80-frontend && terraform destroy -auto-approve && cd ..
cd 70-webalb   && terraform destroy -auto-approve && cd ..
cd 60-backend  && terraform destroy -auto-approve && cd ..
cd 50-alb      && terraform destroy -auto-approve && cd ..
cd 40-rds      && terraform destroy -auto-approve && cd ..
cd 30-vpn      && terraform destroy -auto-approve && cd ..
cd 20-bastion  && terraform destroy -auto-approve && cd ..
cd 10-sg       && terraform destroy -auto-approve && cd ..
cd 00-vpc      && terraform destroy -auto-approve && cd ..
```

### Cost Warnings & Cleanup Caveats
- **EBS Snapshots**: Terraform deregisters custom AMIs on destroy, but underlying EBS snapshots may persist. Check and remove unused snapshots in the EC2 Console.
- **RDS Data Loss**: In `40-rds/rds.tf`, `skip_final_snapshot = true` and `deletion_protection = false`. All data in the `transactions` database is permanently deleted when `40-rds` is destroyed.
- **Remote State Storage**: The S3 bucket `jithesh-tf-remote-state-expense-dev` and DynamoDB table `jithesh-state-locking-expense-dev` are external to these configurations and will not be removed by `destroy.sh`.

---

## Security Considerations

The following findings represent items in the current development codebase to be addressed before promoting to production:

1. **Hardcoded Credentials**: Passwords for SSH bootstrapping, RDS MySQL master user, and OpenVPN admin are committed in plain text in the `.tf` and `.sh` files.
   - *Recommendation*: Rotate all committed credentials immediately. Store secrets in **AWS Secrets Manager** or encrypted SSM Parameter Store (`SecureString`).
2. **Public SSH Ingress**: Security groups `vpn_sg` and `frontend_sg` allow port 22 access from `0.0.0.0/0`.
   - *Recommendation*: Restrict frontend SSH ingress to the Bastion host or replace direct SSH access with AWS Systems Manager Session Manager.
3. **Unencrypted HTTP Listeners**: Both Web ALB and internal App ALB operate on HTTP port 80 without TLS encryption.
   - *Recommendation*: Attach AWS Certificate Manager (ACM) certificates to ALB listeners and enforce HTTPS on port 443 with HTTP-to-HTTPS redirection.
4. **State File Protection**: Terraform state files in S3 contain unencrypted secrets and infrastructure metadata.
   - *Recommendation*: Ensure the remote state bucket enforces SSE-KMS encryption and S3 Block Public Access.

---

## Author and References

- **Infrastructure Repository**: [jitheshl/terraform-expense-dev-infrastructure](https://github.com/jitheshl/terraform-expense-dev-infrastructure.git)
- **Author**: [jitheshl](https://github.com/jitheshl)
- **Ansible Roles**: [expense-ansible-roles-tf](https://github.com/jitheshl/expense-ansible-roles-tf.git)
- **VPC Module**: [terraform-aws-vpc-module](https://github.com/jitheshl/terraform-aws-vpc-module.git)
- **Security Group Module**: [terraform-aws-security-group-module](https://github.com/jitheshl/terraform-aws-security-group-module.git)
