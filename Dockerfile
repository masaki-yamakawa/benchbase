FROM maven:3.6.3-openjdk-17-slim as builder
RUN apt-get update \
  && apt-get install --yes --no-install-recommends git \
  && rm --recursive --force /var/lib/apt/lists/*
COPY . /build/
WORKDIR /build
RUN mvn clean package
ENV BENCHBASE_VERSION=*
RUN tar xvzf /build/target/benchbase-${BENCHBASE_VERSION}.tgz
RUN mv /build/benchbase-${BENCHBASE_VERSION} /app

FROM openjdk:17-alpine3.14
COPY --from=builder /app ./app
WORKDIR /app
ENTRYPOINT ["java","-jar","benchbase.jar"]
CMD ["-h"]
