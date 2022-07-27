FROM arm64v8/alpine:3

RUN apk update
RUN apk add curl unzip which clang build-base git openjdk8

ARG GRADLE_VERSION=7.5
RUN curl -sL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" --output gradle.zip && unzip -q gradle.zip && rm -rf gradle.zip && ln -sf $(pwd)/gradle-*/bin/gradle /usr/bin/

COPY build.gradle /tmp/build.gradle
RUN cd /tmp && gradle downloadDeps && rm -rf /tmp

WORKDIR /root