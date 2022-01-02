FROM maven:3.6.3-openjdk-17-slim as builder
RUN apt-get update \
  && apt-get install --yes --no-install-recommends git \
  && rm --recursive --force /var/lib/apt/lists/*
COPY . /build/
WORKDIR /build
RUN mvn clean package

FROM openjdk:17-slim
COPY --from=builder /build/target/benchbase-2021-SNAPSHOT.tgz .
RUN tar xvzf benchbase-2021-SNAPSHOT.tgz
RUN mv /benchbase-2021-SNAPSHOT /app
WORKDIR /app
CMD bash
