FROM risingstack/alpine:3.4-v6.9.4-4.2.0

# risingstack/alpine default NODE_ENV is production
# It prevents installing npm dev dependencies
ENV NODE_ENV=development

WORKDIR "/home"

# Install ssh client
RUN apk update
RUN apk add openssh-client
RUN apk add bash
RUN rm -rf /var/cache/apk/*

# Install Docker
RUN curl -L -o /tmp/docker.tgz https://get.docker.com/builds/Linux/x86_64/docker-1.12.3.tgz
RUN tar -xz -C /tmp -f /tmp/docker.tgz
RUN mv /tmp/docker/docker* /usr/bin/
RUN curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
RUN chmod +x  /usr/bin/docker-compose

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

# Configure gcloud
RUN gcloud config set component_manager/disable_update_check true
RUN gcloud config set container/use_client_certificate True

# Change working directory back
WORKDIR "/src/node-app"

CMD ["/bin/sh"]
