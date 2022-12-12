FROM jenkins/agent:latest
USER root
RUN apt-get update
RUN echo "Installing curl"
RUN apt-get install -y curl
RUN echo "Installing unzip"
RUN apt-get install -y unzip
RUN unzip -v
RUN echo "Installing Nodejs and npm"
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs
RUN node --version
RUN echo "Installing AWS-CLI"
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install -i /usr/local/aws -b /usr/local/bin/aws