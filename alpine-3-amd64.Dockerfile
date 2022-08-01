FROM amd64/alpine:3

RUN apk update
RUN apk add curl unzip which clang build-base git openjdk8

ARG GRADLE_VERSION=7.5
RUN curl -sL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" --output gradle.zip && unzip -q gradle.zip && rm -rf gradle.zip && ln -sf $(pwd)/gradle-*/bin/gradle /usr/bin/
RUN mkdir -p tmp && cd tmp && gradle init --no-daemon -i --type java-application --test-framework junit --dsl groovy --project-name tmp --package tmp --incubating
COPY build.gradle /tmp/app/build.gradle
RUN cd tmp/app && gradle --no-daemon -i downloadDeps build run jacocoTestReport spotlessCheck && cd / && rm -rf /tmp && mkdir -p /tmp