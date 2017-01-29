FROM risingstack/alpine:3.4-v6.9.4-4.2.0

WORKDIR "/home"

# Install Docker
RUN curl -L -o /tmp/docker.tgz https://get.docker.com/builds/Linux/x86_64/docker-1.12.3.tgz
RUN tar -xz -C /tmp -f /tmp/docker.tgz
RUN mv /tmp/docker/docker* /usr/bin/

# Install gcloud
RUN curl -L -o google-cloud-sdk.zip https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip
RUN unzip google-cloud-sdk.zip
RUN rm google-cloud-sdk.zip
RUN google-cloud-sdk/install.sh\
  --usage-reporting=false\
  --bash-completion=true\
  --path-update=true\
  --rc-path=/.bashrc\
  --additional-components kubectl

# Add gcloud and kubectl to PATH
ENV PATH="/home/google-cloud-sdk/bin:${PATH}"

# Disable gcloud check auto updater
RUN gcloud config set component_manager/disable_update_check true 

# Change working directory back
WORKDIR "/src/node-app"

CMD ["bin/sh"]
