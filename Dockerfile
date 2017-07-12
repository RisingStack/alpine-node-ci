FROM risingstack/alpine:3.4-v8.1.4-4.5.1

# risingstack/alpine default NODE_ENV is production
# It prevents installing npm dev dependencies
ENV NODE_ENV=development
ENV GLIBC_VERSION 2.23-r3

WORKDIR "/home"

# Install ssh client
RUN apk update \
  && apk add openssh-client bash tar gzip jq wget \
  && update-ca-certificates

# https://github.com/browserstack/browserstack-local-nodejs/issues/20
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk" \
  && apk --no-cache add "glibc-$GLIBC_VERSION.apk" \
  && rm "glibc-$GLIBC_VERSION.apk" \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk" \
  && apk --no-cache add "glibc-bin-$GLIBC_VERSION.apk" \
  && rm "glibc-bin-$GLIBC_VERSION.apk" \
  && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-i18n-$GLIBC_VERSION.apk" \
  && apk --no-cache add "glibc-i18n-$GLIBC_VERSION.apk" \
  && rm "glibc-i18n-$GLIBC_VERSION.apk"

# Empty apk cache
RUN rm -rf /var/cache/apk/*

# Install Docker
RUN curl -L -o /tmp/docker.tgz https://get.docker.com/builds/Linux/x86_64/docker-1.12.3.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/docker* /usr/bin/ \
  && curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose \
  && chmod +x  /usr/bin/docker-compose

# Install gcloud
RUN curl -L -o google-cloud-sdk.zip https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip \
  && unzip google-cloud-sdk.zip \
  && rm google-cloud-sdk.zip \
  && google-cloud-sdk/install.sh \
  --usage-reporting=false\
  --bash-completion=true\
  --path-update=true\
  --rc-path=/.bashrc\
  --additional-components kubectl

# Add gcloud and kubectl to PATH
ENV PATH="/home/google-cloud-sdk/bin:${PATH}"

# Configure gcloud
RUN gcloud config set component_manager/disable_update_check true \
  && gcloud config set container/use_client_certificate True

# Install BrowserStackLocal
RUN mkdir browserstack-local && \
  cd browserstack-local && \
  curl -O https://www.browserstack.com/browserstack-local/BrowserStackLocal-linux-x64.zip && \
  unzip BrowserStackLocal-linux-x64.zip && \
  rm BrowserStackLocal-linux-x64.zip && \
  cd ..

# Add BrowserStackLocal to PATH
ENV PATH="/home/browserstack-local:${PATH}"

# Change working directory back
WORKDIR "/src/node-app"

CMD ["/bin/sh"]
