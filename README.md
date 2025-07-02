**Step 1: VPC & Subnet Setup**

Create a custom network environment.

	1. Create a VPC

		○ Name: login-vpc

		○ CIDR: 10.0.0.0/16

	2. Create 2 Public Subnets

		○ subnet-public-1: 10.0.1.0/24 (AZ1)

		○ subnet-public-2: 10.0.2.0/24 (AZ2)

	3. Create 2 Private Subnets

		○ subnet-private-1: 10.0.3.0/24 (AZ1)

		○ subnet-private-2: 10.0.4.0/24 (AZ2)

	4. Create an Internet Gateway

		○ Attach it to login-vpc.

	5. Route Tables

		○ Public route table with 0.0.0.0/0 → Internet Gateway

		○ Associate it with public subnets.
  
  		○ Private route table with 0.0.0.0/0 → NAT Gateway

		○ Associate it with private subnets.
  		

	6. Create NAT Gateway

		○ Deploy in a public subnet.

		○ Allocate Elastic IP.

		○ Private subnets route 0.0.0.0/0 → NAT Gateway.

  


**Step 2: Create RDS (MySQL) Instance**

	1. Go to RDS → Databases → Create database

	2. Choose:

		○ Engine: MySQL

		○ Version: 8.x

		○ DB instance identifier: login-db

		○ Master username: admin

		○ Master password: yourpassword

	3. DB Instance Size: db.t3.micro (for test)

	4. Storage: 20GB (default)

	5. Connectivity:

		○ VPC: login-vpc

		○ Subnet group: select private subnets
		
		○ Public access: No

		○ VPC security group: Create or use one that allows inbound MySQL (3306) from EC2's SG

	6. Enable backups if needed.




**Step 3: Create Users Table in MySQL**

Once RDS is up:

	1. Connect using a MySQL client or MySQL Workbench:

    mysql -h <RDS-ENDPOINT> -u admin -p

	2. Create DB & table:

    CREATE DATABASE loginapp;

    USE loginapp;


  CREATE TABLE users (

  id INT AUTO_INCREMENT PRIMARY KEY,

  username VARCHAR(50),

  password VARCHAR(50)

);

INSERT INTO users (username, password) VALUES ('admin', 'admin123');

SELECT * FROM users;


 3. Test with cURL or Postman

  curl -X POST http://localhost:3000/login \

  -H "Content-Type: application/json" \

  -d '{"username":"admin", "password":"admin123"}'



**Step 4: Backend (Python Flask in Docker)**

Project structure:


be/

|── .env

|── app.py

|── dockerfile

|── requirements.txt



**Step 5: Push Backend Docker Image to Amazon ECR**

	1. Create ECR Repo

aws ecr create-repository --repository-name login-backend

	
  2. Authenticate Docker

aws ecr get-login-password | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
		

  3. Build & Push

docker build -t login-backend .

docker tag login-backend:latest <account_id>.dkr.ecr.<region>.amazonaws.com/login-backend

docker push <account_id>.dkr.ecr.<region>.amazonaws.com/login-backend



**Step 6: Launch Backend EC2 Instance**

1. Launch EC2 in public subnet

      Use Amazon Linux 2023

      Attach IAM role with ECR & SSM permissions


3. Install Docker on Amazon Linux 2023 

			sudo dnf update -y 

			sudo dnf install -y docker awscli 

				
4. Start Docker 

			sudo systemctl start docker 

			sudo systemctl enable docker 

				
5. Add ec2-user to docker group 

			sudo usermod -aG docker ec2-user 

				
6. Login to ECR (assumes IAM role is attached!) 

			aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin <ecr-url>

				
7. Pull and run the Docker container 

			sudo docker pull <ecr-url>/login-backend


			sudo docker run -d -p 80:3000  -e DB_HOST=<RDS-ENDPOINT> <ecr-url>/login-backend


				
**Step 7: Frontend Login Page (HTML)**

Project structure:


fe/

|── dockerfile

|── index.html


**Step 8: Push Frontend Docker Image to Amazon ECR && Launch Backend EC2 Instance**


