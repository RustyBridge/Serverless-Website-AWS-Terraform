## **Serverless Website on AWS using Terraform**

A project where I aimed to host my Resume at https://gvasilopoulos.xyz, using AWS services, provisioned with Terraform. The inspiration came from The Cloud Resume Challenge (https://cloudresumechallenge.dev/docs/the-challenge/aws/)

### **Architecture diagram:**

![Diagram drawio](https://user-images.githubusercontent.com/68524920/205506532-4ce35c72-f998-4311-bc88-40d8f25428c5.png)


### **Description:**
1.	The frontend was created by my brother and talented developer @Nick Vasilopoulos, using React, contains a visitor counter written in JavaScript and the static website is hosted on S3
2.	A domain name was registered and Route53 is used to manage its DNS records.
3.	Cloudfront is used to Distribute the website
4.	The JS Counter calls an API (API Gateway + Custom domain name), which in turn triggers a Lambda function which runs a Python script. The script reads the value for the visitor count, from a DynamoDB table, increments the value by 1 and returns the new value to be displayed on the website.


### **Disclaimer:**
1.	The Frontend was not created by me. All credits go to @Nick Vasilopoulos (https://www.linkedin.com/in/nickvasilopoulos/)
2.	The Python script was found online (I edited it to use a variable in the DB table name so it is generated each time the TF configuration runs)
3.	The SSL certificate, the Route53 CNAME record used for DNS validation as well as the domain’s NS and SOA records were created using the AWS Console.
