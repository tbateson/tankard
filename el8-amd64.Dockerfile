FROM centos:8

RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum update -y
RUN yum install -y curl unzip which clang gcc-c++ git && rm -rf /var/cache/yum

ARG ADOPTIUM_JDK_URL=https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u342-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u342b07.tar.gz
RUN curl -sL "$ADOPTIUM_JDK_URL" --output adoptium_jdk.tar.gz && tar -xzf adoptium_jdk.tar.gz && rm -rf adoptium_jdk.tar.gz && ln -sf $(pwd)/jdk8u*/bin/java /usr/bin/

ARG GRADLE_VERSION=7.5
RUN curl -sL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" --output gradle.zip && unzip -q gradle.zip && rm -rf gradle.zip && ln -sf $(pwd)/gradle-*/bin/gradle /usr/bin/

COPY build.gradle /tmp/build.gradle
RUN cd /tmp && gradle downloadDeps && rm -rf /tmp

WORKDIR /root