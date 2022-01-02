FROM maven:3.6.3-openjdk-17-slim as builder
RUN apt-get update \
  && apt-get install --yes --no-install-recommends git \
  && rm --recursive --force /var/lib/apt/lists/*
COPY . /build/
WORKDIR /build
RUN mvn clean package

FROM openjdk:17-slim
ENV BENCHBASE_VERSION=2021-SNAPSHOT
COPY --from=builder /build/target/benchbase-${BENCHBASE_VERSION}.tgz .
RUN tar xvzf benchbase-${BENCHBASE_VERSION}.tgz
RUN mv /benchbase-${BENCHBASE_VERSION} /app
WORKDIR /app
ENTRYPOINT ["java","-jar","benchbase.jar"]
CMD ["-h"]
