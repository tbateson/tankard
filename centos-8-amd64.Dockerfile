FROM centos:8

RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum update -y
RUN yum install -y curl unzip which clang gcc-c++ git && rm -rf /var/cache/yum

ARG ADOPTIUM_JDK_URL=https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u342-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u342b07.tar.gz
RUN curl -sL "$ADOPTIUM_JDK_URL" --output adoptium_jdk.tar.gz && tar -xzf adoptium_jdk.tar.gz && rm -rf adoptium_jdk.tar.gz && ln -sf /jdk8u*/bin/* /usr/bin/

ARG GRADLE_VERSION=7.5
RUN curl -sL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" --output gradle.zip && unzip -q gradle.zip && rm -rf gradle.zip && ln -sf /gradle-*/bin/gradle /usr/bin/
RUN mkdir -p tmp && cd tmp && gradle init --no-daemon -i --type java-application --test-framework junit --dsl groovy --project-name tmp --package tmp --incubating
COPY build.gradle /tmp/app/build.gradle
RUN cd tmp/app && gradle --no-daemon -i downloadDeps build run jacocoTestReport spotlessCheck && cd / && rm -rf /tmp && mkdir -p /tmp

ARG SONAR_VERSION=4.7.0.2747
RUN curl -sL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_VERSION-linux.zip" --output sonar-scanner.zip && unzip -q sonar-scanner.zip && rm -rf sonar-scanner.zip && ln -sf /sonar-scanner-*-linux/bin/* /usr/bin