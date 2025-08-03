# 🚀 EC2 Provisioning with Terraform and Configuration with Ansible

## 🎯 Prerequisites

Before you start, make sure you have:

- **AWS Account**
- **AWS Credentials** configured (`~/.aws/credentials`)
- **Terraform** installed
- **Ansible** installed
- An **SSH key pair** (e.g., `my-key.pem`)

---

## 🚀 Terraform Setup

### 📁 Project Folder Structure

Structure your project as shown below:

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

---

## 🔄 Running the Playbook

After generating the `inventory.ini` file using `./generate_in.sh`, execute the playbook with:

```bash
ansible-playbook -i inventory.ini playbook.yml
```
