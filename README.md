# 🚀 EC2 Provisioning with Terraform and Configuration with Ansible

## 📦 Prerequisites

- AWS account
- AWS credentials configured (`~/.aws/credentials`)
- `terraform` installed
- `ansible` installed
- SSH key pair (e.g., `my-key.pem`)

---

## 1. 🔧 Terraform Setup

### 📁 Folder Structure

```bash
project/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   ├── flask-backend.service
│   └── express-frontend.service
```
