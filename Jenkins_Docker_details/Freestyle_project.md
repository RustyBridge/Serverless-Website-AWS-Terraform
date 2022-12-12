# Overview of the Jenkins Freestyle Project

### 1. Run and Configured the Jenkins master on a Docker container

### 2. Build a Docker image from jenkins/agent, added nodejs/npm and awscli

### 3. Created a Docker Cloud and an agent template, which uses the custom Docker image

### 4. Created a Freestyle Jenkins Project with the following configuration:

A. Github project: https://github.com/RustyBridge/georgeresume/

B. Restrict where this project can be run: Docker_Cloud_Agent_name

C. Source Code Management: Git\
    Repo URL: https://github.com/RustyBridge/georgeresume/ \
    Credentials: GitHub Token\
    branch: */main

D. Build Triggers: Poll SCM\
    Schedule: H/5 * * * *

E. Delete workspace before build starts

F. Use secret texts:\
    AWS_ACCESS_KEY_ID\
    AWS_SECRET_ACCESS_KEY\
    NPM_TOKEN

G. Build Steps:\
Execute shell:
```
        echo "STEP 3: NPM build"
        echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" >> .npmrc;
        npm init --yes;
        rm -rf Jenkins_Docker_details;
        rm package-lock.json;
        npm install;
        CI=false npm run build;  
```

Ececute shell:
```
        echo "STEP 3: AWS copy build to S3"
        ln -s /usr/local/bin/aws/aws /usr/bin/aws
        aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID};
        aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY};
        aws configure set default.region us-east-1;
        aws s3 rm --recursive s3://gvasilopoulos.xyz;
        aws s3 sync /home/jenkins/workspace/my-test-s3-upload-poject/build/ s3://gvasilopoulos.xyz/;
```
### 5. Pushed a new commit to the repository, the app was built and the contents of the build folder were uploaded to S3.