## **Serverless Website on AWS using Terraform**

A project where I aimed to host my Resume at https://gvasilopoulos.xyz, using AWS services, provisioned with Terraform. The inspiration came from The Cloud Resume Challenge (https://cloudresumechallenge.dev/docs/the-challenge/aws/)

### **Architecture diagram:**

![Architecture_Github drawio](https://user-images.githubusercontent.com/68524920/227622737-a6f64571-5f11-4f43-8e6b-f11d0a33c565.png)

### **Description:**
1.	The frontend was created using React, it contains a visitor counter written in JavaScript and the static website is hosted on S3
2.	A domain name was registered and Route53 was used to manage its DNS records.
3.	Cloudfront is used for security and to distribute the website efficiently
4.	Two APIs and a Gateway were created, a custom domain name and the relevant mappings
5.	Two Lambda functions were created, one to read the value from the DB and return it and the other to read, increment the value in the DB and return it. Each Lamba is triggered by a different API.
6.	The Javascript function:\
a) Checks the local storage for the value and if it doesn’t exist it, calls API2, which invokes the Lambda responsible for incrementing the DB value, saves it to local storage and displays it.\
b) If the value already exists in local storage (the website has already been visited) calls API1 which invokes the Lambda responsible for reading the updated value from the DB, saves it to the local storage and displays it. 
7. A CD Pipeline was created for the frontend, using Jenkins and Docker, which builds the React app and copies the contents of the build folder to the S3 bucket, when changes are pushed to that private repository. The details are described here: https://github.com/RustyBridge/Serverless-Website-AWS-Terraform/blob/5f5b5968b9b172ac9e4f5eb932dc14c5defae010/Jenkins_Docker_details/Freestyle_project.md


### **Disclaimer:**
 1.	The Frontend was not created by me. All credits go to my brother and talented developer, Nick Vasilopoulos (https://www.linkedin.com/in/nickvasilopoulos/)
 2.	The Python script was found online (I edited it to use a variable in the DB table name so it is generated each time the TF configuration runs)
 3.	The SSL certificate, the Route53 CNAME record used for DNS validation as well as the domain’s NS and SOA records were created using the AWS Console and imported to the Terraform configuration.
