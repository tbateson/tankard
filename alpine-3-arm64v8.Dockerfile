FROM arm64v8/alpine:3

RUN apk update
RUN apk add curl unzip which clang build-base git openjdk11

ARG GRADLE_VERSION=7.6
RUN curl -sL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" --output gradle.zip && unzip -q gradle.zip && rm -rf gradle.zip && ln -sf /gradle-*/bin/gradle /usr/bin/
RUN mkdir -p tmp && cd tmp && gradle init --no-daemon -i --type java-application --test-framework junit --dsl groovy --project-name tmp --package tmp --incubating
RUN echo 'org.gradle.cache.cleanup=false' >> ~/.gradle/gradle.properties
COPY build.gradle /tmp/app/build.gradle
RUN cd tmp/app && gradle --no-daemon -i downloadDeps build run jacocoTestReport spotlessCheck && cd / && rm -rf tmp && mkdir -p tmp

ARG SONAR_VERSION=4.7.0.2747
RUN curl -sL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_VERSION-linux.zip" --output sonar-scanner.zip && unzip -q sonar-scanner.zip && rm -rf sonar-scanner.zip && sed -i "s|use_embedded_jre=true|use_embedded_jre=false|" "/sonar-scanner-$SONAR_VERSION-linux/bin/sonar-scanner" && rm -rf "/sonar-scanner-$SONAR_VERSION-linux/jre" && ln -sf /sonar-scanner-*-linux/bin/* /usr/bin