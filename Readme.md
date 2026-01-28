# 3-Tier Infrastructure Deployment Using Terraform Modules & Ansible
## Project Overview
This project demonstrates a real-world 3-tier AWS architecture using Terraform for infrastructure provisioning and Ansible for configuration management.
## Objective

To design and deploy a secure, scalable 3-tier web application architecture on AWS using:
- Terraform for infrastructure provisioning
- Ansible for configuration management
- NGINX reverse proxy for secure request routing
- Amazon RDS as a managed database service

## Architecture Flow
```bash
User Browser
     |
     v
Web Tier (Public Subnet)
NGINX + HTML Form
     |
     v
Application Tier (Private Subnet)
Apache + PHP (submit.php)
     |
     v
Database Tier (Private Subnet)
Amazon RDS (MySQL)

```
## Project Structure
```bash
terraform-3-tier/
│
├── main.tf
├── variables.tf
├── outputs.tf
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── web/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── ansible/
    ├── hosts.ini
    ├── site.yml
    └── files/
        ├── index.html
        └── submit.php
```

## Tools Used
- AWS
- Terraform
- Ansible
- NGINX
- Apache
- PHP
- Amazon RDS


## Steps to Do
1. Provision VPC, EC2, and RDS using Terraform modules
2. Configure Web & App servers using Ansible
3. Implement NGINX reverse proxy
4. Connect App Tier to RDS
5. Validate end-to-end data flow

## Step 1. Infrastructure Provisioning (Terraform)
### Terraform Modules Used
```
── modules/
   |
   ├── vpc/   
   │
   ├── web/   
   │
   └── rds/
```
## Terraform Implementation – Step by Step
### 1) VPC Module - [VPC Module](modules/vpc)
- Custom VPC
- 2 Public Subnets (Web Tier)
- 2 Private Subnets (App & DB Tier)
- Internet Gateway
- NAT Gateway
- Route Tables & Associations
### 2) Module Web ( EC2 )-  [Web Module](modules/web)
#### Web Tier

- EC2 in public subnet
- Public IP enabled
- Security Group allows HTTP (80) & SSH (22)

#### App Tier (Created from main.tf using web module)
- EC2 in private subnet
- No public IP
- Security Group allows HTTP only from Web Tier

### 3) Database Tier - [RDS Module](modules/rds)
- Amazon RDS (MySQL)
- DB Subnet Group with private subnets
- Security Group allows MySQL (3306) only from App Tier

### Step 2. Root main.tf (Glue Everything)
### [Main.tf file](main.tf)

### Step 3. Terraform Execution
```bash
# Initialize Terraform

terraform init

# Plan

terraform plan

# Apply Infrastructure

terraform apply
```

- Get the outputs 
![alt text](<img/Screenshot 2026-01-28 133618.png>)
### Infrastructure is now live & created whole Infra
- Instances created by Terraform
![alt text](<img/Screenshot 2026-01-28 133729.png>)
- VPC created by Terraform
![alt text](<img/Screenshot 2026-01-28 133820.png>)
- RDS created by Terraform
 ![alt text](<img/Screenshot 2026-01-28 133853.png>)

##  Ansible (Configuration Management)
### Step 4. Install ansible on Web EC2
- Connect with web server
```bash
ssh -i <key> ec2-user@<public-ip>
``` 
- after that update the server
- install ansible
```bash
sudo yum install ansible -y
```
### Step 5. Create ansible structure 
```
ansible/
├── hosts.ini
├── site.yml
└── files/
    ├── index.html
    └── submit.php

```

### Step 6. Configure Ansible Inventory
### [hosts.ini](ansible/hosts.ini)

### Step 7. Web Tier Configuration (NGINX)
- Install NGINX
- Serve HTML form
- Reverse proxy to App tier
- `files/index.html`
```bash
<form action="/submit" method="POST">
  Name: <input name="name">
  Email: <input name="email">
  <input type="submit">
</form>

```
### [index.html](ansible/files/index.html)

### Step 8. Reverse Proxy Setup
- NGINX forwards /submit to App EC2:
```bash

location /submit {
    proxy_pass http://10.0.100.67/submit.php;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}


```
[See Proxy setup in site.yml file](ansible/site.yml)
### Step 9. App Tier Configuration (Apache + PHP)
- Install Apache
- Install PHP & MySQL extension
- Deploy submit.php
```bash
<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$host = "terraform-20260128080025515100000004.c4ji0qekmizd.us-east-1.rds.amazonaws.com";
$user = "admin";
$pass = "admin1234";
$db   = "mydatabase";

$conn = new mysqli($host, $user, $pass, $db, 3306);

if ($conn->connect_error) {
    die("DB Connection Failed: " . $conn->connect_error);
}

$name  = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';

if ($name && $email) {
    $sql = "INSERT INTO users (name, email) VALUES ('$name', '$email')";
    if ($conn->query($sql)) {
        echo "Registration Successful";
    } else {
        echo "Insert failed";
    }
} else {
    echo "Invalid input";
}

$conn->close();
?>

```
### [Submit.php](ansible/files/submit.php)
![alt text](<img/Screenshot 2026-01-28 143026.png>)

### Step 10. Run Ansible
```bash
ansible-playbook -i hosts.ini site.yml
```

![alt text](<img/Screenshot 2026-01-28 140118.png>)

### Step 11. Final End-to-End Test
- Open Browser & hit
```
http://<WEB_PUBLIC_IP>
```
![alt text](<img/Screenshot 2026-01-28 140221.png>)

- And then fiil form
![alt text](<img/Screenshot 2026-01-28 140242.png>)

- Click Submit
- But after clicking on submit their was an error occurs
```
Fatal error: Uncaught mysqli_sql_exception: Table 'mydatabase.users' doesn't exist in /var/www/html/submit.php:21 Stack trace: #0 /var/www/html/submit.php(21): mysqli->query() #1 {main} thrown in /var/www/html/submit.php on line 21
```
- The Error explained-
```
Table 'mydatabase.users' doesn't exist
```
- Table `users`  is missing

### Step 12. Connect to RDS from APP EC2
- Connect to Web server
- From Web server connect to App Server
![alt text](<img/Screenshot 2026-01-28 142941.png>)
- and then install mysql to connect database
```bash
sudo yum install mariadb105-server -y

#enable and start Mariadb

sudo systemctl start mariadb 
sudo systemctl enable mariadb

```
- after installation connecct to RDS
```bash
mysql -h terraform-20260128080025515100000004.c4ji0qekmizd.us-east-1.rds.amazonaws.com -P 3306 -u admin -p
```
- Select Database

```bash
show database;
use database;
```

- Create Table `users` inside `mydatabase`
```bash
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);
```
- Now Exit;
### Fill form and check the result
- Now after filling form its show Successfully Register

![alt text](<img/Screenshot 2026-01-28 142507.png>)

### Also verify data in RDS
 - Connect to RDS and see the Table user store the values

 ![alt text](<img/Screenshot 2026-01-28 142628.png>)

 ## How It Works
```
Browser → Web Tier (NGINX) → App Tier (Apache + PHP) → RDS (MySQL)
```
## Finally Secure and automated 3-tier architecture deployed successfully


## Common Issues Faced and  Fixes (REAL TIME)

- SSH Permission denied = `chmod 400 key.pem`
- submit.php timeout = Implemented NGINX reverse Proxy
- HTTP 500 error = Fixed PHP MYSQL Connection
- Table not Found = Created DB schema

# Summary
Designed and deployed a complete 3-tier web application architecture on AWS using Terraform modules and Ansible automation. The project includes a custom VPC with public and private subnets across multiple Availability Zones, an Internet Gateway and NAT Gateway for controlled internet access, and secure routing using route tables and security groups. The web tier, hosted in a public subnet, runs NGINX to serve an HTML registration form and acts as a reverse proxy to the application tier. The application tier, deployed in a private subnet, uses Apache and PHP to process user submissions and securely connect to an Amazon RDS MySQL database hosted in a private subnet. Terraform was used to provision and manage all infrastructure components in a modular and reusable manner, while Ansible automated server configuration, package installation, and application deployment. This project demonstrates real-world DevOps practices including infrastructure as code, configuration management, network isolation, and secure multi-tier application design.