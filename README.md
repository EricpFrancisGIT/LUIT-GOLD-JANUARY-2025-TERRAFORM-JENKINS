# Jenkins on AWS via Terraform

Spin up a single Ubuntu EC2 in your **default VPC**, bootstrap **Jenkins** automatically, expose ports **22/8080**, and create a private **S3 artifacts bucket**. (Complex tier adds an **IAM role** on the instance with scoped S3 read/write.)

---

## What you deploy

* **EC2 (Ubuntu 22.04 LTS)** with Jenkins installed & started via cloud-init `user-data.sh` (Java 17)
* **Security Group** allowing SSH from your IP (22) and Jenkins UI (8080)
* **S3 bucket** for Jenkins artifacts with **public access fully blocked** and TLS-only policy
* (Complex) **IAM role + instance profile** granting **bucket‑scoped S3 read/write** (+ optional SSM Managed Core for easier ops)

---

## Repo structure

```
jenkins-on-aws-terraform/
├─ README.md
├─ providers.tf
├─ variables.tf
├─ outputs.tf
├─ main.tf
├─ networking.tf
├─ compute.tf
├─ s3.tf
├─ iam.tf
└─ user-data.sh
```

---

## Prerequisites

* Terraform **>= 1.6**
* AWS credentials configured (env vars, shared config, or SSO)
* Existing EC2 **key pair** if you want SSH access (`var.key_name`)
* A **globally unique** S3 bucket name for artifacts (`var.bucket_name`)

---

## Quick start

```bash
# 1) Clone and enter repo
# git clone https://github.com/<you>/jenkins-on-aws-terraform.git
# cd jenkins-on-aws-terraform

# 2) Configure variables
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your values (region, bucket_name, allowed_ssh_cidr, etc.)

# 3) Validate & apply
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

**Outputs** will include:

* `jenkins_public_ip`
* `jenkins_url` – visit in your browser (port `8080`)
* `artifacts_bucket`

---

## Configuration

### Variables

| Name               | Type         | Default          | Description                           |
| ------------------ | ------------ | ---------------- | ------------------------------------- |
| `project_name`     | string       | `"jenkins-demo"` | Logical name prefix for resources     |
| `env`              | string       | `"staging"`      | Environment label (staging/prod/etc.) |
| `aws_region`       | string       | `"us-east-1"`    | Deploy region                         |
| `allowed_ssh_cidr` | string       | `"0.0.0.0/0"`    | **Change to your** `/32` for SSH      |
| `instance_type`    | string       | `"t3.small"`     | EC2 instance type                     |
| `key_name`         | string\|null | `null`           | Existing key pair name (optional)     |
| `bucket_name`      | string       | —                | **Required** – unique S3 bucket name  |
| `root_volume_size` | number       | `20`             | Root EBS volume (GiB)                 |

### Example `terraform.tfvars`

```hcl
aws_region       = "us-east-1"
project_name     = "jenkins-demo"
env              = "staging"
allowed_ssh_cidr = "203.0.113.10/32"  # your IP
instance_type    = "t3.small"
bucket_name      = "your-unique-jenkins-artifacts-bucket"
key_name         = "your-ec2-keypair"
```

---

## Access Jenkins

1. Open the output `jenkins_url` in your browser (e.g., `http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:8080`).
2. Retrieve the **initial admin password** on the instance:

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   # also echoed by user-data to:
   sudo cat /var/log/jenkins-initial-password
   ```
3. Complete setup wizard and install suggested plugins.

> Jenkins install follows the official Debian/Ubuntu repo method described at [https://www.jenkins.io/doc/book/installing/linux/](https://www.jenkins.io/doc/book/installing/linux/).

---

## (Complex) Validate instance IAM → S3 access

Without placing any AWS credentials on the instance:

```bash
aws sts get-caller-identity
aws s3 ls s3://$BUCKET
aws s3 cp /etc/hostname s3://$BUCKET/test/hostname.txt
aws s3 rm s3://$BUCKET/test/hostname.txt
```

These should succeed via the attached instance **role** and the bucket‑scoped policy.

---

## Security notes

* Restrict SSH (`allowed_ssh_cidr`) to your **/32**.
* S3 bucket is private with public access blocked; a TLS‑only bucket policy is included.
* For production, front Jenkins with an **ALB + HTTPS** and restrict 8080 to the ALB only.

---

## Troubleshooting

* **Can’t reach 8080?**

  * Confirm SG inbound rule for 8080 and that the instance has a **public IP**.
  * On the instance:

    ```bash
    sudo systemctl status jenkins
    sudo journalctl -u jenkins -n 200 --no-pager
    sudo tail -n 200 /var/log/cloud-init-output.log
    ```
* **Bucket name already taken**: choose another globally unique name.
* **SSH fails**: verify your key pair, the correct `ubuntu@<public_ip>` user, and your IP CIDR.

> Tip: If your default subnet doesn’t auto‑assign a public IP, set `associate_public_ip_address = true` on the instance (or enable it at the subnet level).

---

## Clean up

```bash
terraform destroy
```

This removes the EC2 instance, SG, bucket policy, IAM role/profile, and the bucket (if empty). If the bucket contains objects, empty it first.

---

## Contributing / Forking

* Add a .gitignore to avoid committing state:

  ```gitignore
  .terraform/
  *.tfstate
  *.tfstate.backup
  terraform.tfvars
  .terraform.lock.hcl
  ```
* Open PRs for improvements (HTTPS via ALB, automated backups, Jenkins systemd hardening, CloudWatch dashboards, etc.).

---

## Screenshots

Include a screenshot of the Jenkins login/unlock page (port 8080) in your documentation (e.g., `docs/screenshots/jenkins-login.png`).

---

## License

MIT (or your preferred OSS license).
