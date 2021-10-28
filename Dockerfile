FROM ubuntu:focal

ENV TZ=Asia/Jakarta

ENV MONGO_URI=localhost
ENV MONGO_PORT=27017

ARG MONGO_BI_VERSION=2.14.4
ENV MONGO_BI_VERSION=${MONGO_BI_VERSION}

WORKDIR /root

RUN apt update && apt install -y \
    libgssapi-krb5-2 \
    tzdata \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://info-mongodb-com.s3.amazonaws.com/mongodb-bi/v2/mongodb-bi-linux-x86_64-ubuntu2004-v${MONGO_BI_VERSION}.tgz

RUN tar -xvzf mongodb-bi-linux-x86_64-ubuntu2004-v${MONGO_BI_VERSION}.tgz && \
    rm mongodb-bi-linux-x86_64-ubuntu2004-v${MONGO_BI_VERSION}.tgz
RUN install -m755 mongodb-bi-linux-x86_64-ubuntu2004-v${MONGO_BI_VERSION}/bin/mongo* /usr/bin/

# Using self-signed SSL
RUN openssl req -nodes -newkey rsa:2048 -keyout selfsign.key -out selfsign.crt -x509 -days 365 \
    -subj "/C=US/ST=test/L=test/O=test Security/OU=IT Department/CN=test.com" \
    && cat selfsign.crt selfsign.key > selfsign.pem

EXPOSE 3307

CMD exec mongosqld \
    --auth \
    --addr 0.0.0.0 \
    --sslMode allowSSL \
    --sslPEMKeyFile=selfsign.pem \
    --defaultAuthSource ${MONGO_DB} \
    --mongo-uri mongodb://${MONGO_URI}:${MONGO_PORT} \
    --mongo-authenticationSource ${MONGO_DB} \
    --mongo-username ${MONGO_USERNAME} \
    --mongo-password ${MONGO_PASSWORD}