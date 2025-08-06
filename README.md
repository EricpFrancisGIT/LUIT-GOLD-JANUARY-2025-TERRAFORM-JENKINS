# 🚀 Jenkins CI/CD Server on AWS using Terraform

This project provisions a **Jenkins CI/CD server** on an EC2 instance using **Terraform** in your AWS account. The Jenkins server is bootstrapped via user data on launch and is accessible via port `8080`. The setup includes security best practices such as IP-restricted SSH access and private S3 artifact storage.

> **Project Tiers:**
> - ✅ **Foundational**: Monolithic `main.tf` with hardcoded values
> - ✅ **Advanced**: Modular codebase with `variables.tf`, `providers.tf`, and reusable components
> - ✅ **Complex**: IAM Role with S3 read/write access for Jenkins, verified via AWS CLI

---

## 📁 Project Structure

```bash
jenkins-terraform-ec2/
├── main.tf              # Core Terraform configuration (EC2, S3, SG, IAM)
├── variables.tf         # Variables for environment customization
├── providers.tf         # AWS provider definition
├── outputs.tf           # Useful output values like EC2 public IP
├── user-data.sh         # Script to install and start Jenkins
├── README.md            # Project documentation
└── screenshots/
    └── jenkins-login.png

🛠️ Features

    🖥️ Provisions a Jenkins EC2 instance in the default VPC

    🔐 Configures security groups for ports 22 and 8080

    🪣 Creates a private S3 bucket for Jenkins artifacts

    🔁 Bootstraps EC2 instance with Jenkins installation script

    🔑 IAM Role grants Jenkins EC2 instance access to S3

    ✅ Verified Jenkins UI access and S3 CLI interaction

📸 Jenkins Screenshot

🧪 How to Use
1. Clone the Repo
git clone https://github.com/YOUR-USERNAME/jenkins-terraform-ec2.git
cd jenkins-terraform-ec2

2. Initialize Terraform

terraform init

3. Review and Apply the Plan

terraform plan
terraform apply

4. Access Jenkins

    Open your browser

    Navigate to: http://<EC2-PUBLIC-IP>:8080

    Unlock Jenkins using the admin password from /var/lib/jenkins/secrets/initialAdminPassword

5. Validate S3 Access (Complex Tier)

aws s3 ls s3://<your-bucket-name> --region <your-region>

🔧 Sample Pipeline (Optional)

You can optionally add a sample Jenkins pipeline using a basic Jenkinsfile. Refer to Jenkins documentation:

    https://www.jenkins.io/doc/book/pipeline/getting-started/

✅ Prerequisites

    AWS CLI configured with appropriate credentials

    Terraform installed

    SSH key pair (for connecting to EC2, if needed)

🔐 Security Considerations

    SSH restricted to your IP only

    S3 bucket is private

    IAM role with scoped permissions (S3 only)

🌐 GitHub Repository

🔗 GitHub Repository Link
📜 License

This project is licensed under the MIT License.
🙌 Acknowledgments

    Jenkins Installation Docs

    Terraform AWS Provider


Thank you
---