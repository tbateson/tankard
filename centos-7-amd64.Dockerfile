FROM centos:7

RUN yum update -y
RUN yum install -y curl unzip which clang gcc-c++ git && rm -rf /var/cache/yum
RUN git config --system --add safe.directory '*'

ARG ADOPTIUM_JDK_URL=https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.21%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.21_9.tar.gz
RUN curl -sL "$ADOPTIUM_JDK_URL" --output adoptium_jdk.tar.gz && tar -xzf adoptium_jdk.tar.gz && rm -rf adoptium_jdk.tar.gz && ln -sf /jdk*/bin/* /usr/bin/

ARG GRADLE_VERSION=8.5
RUN curl -sL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" --output gradle.zip && unzip -q gradle.zip && rm -rf gradle.zip && ln -sf /gradle-*/bin/gradle /usr/bin/
RUN mkdir -p /root/.gradle && echo 'org.gradle.cache.cleanup=false' >> /root/.gradle/gradle.properties
RUN mkdir -p tmp && cd tmp && gradle init --no-daemon -i --type java-application --test-framework junit --dsl groovy --project-name tmp --package tmp --incubating
COPY build.gradle /tmp/app/build.gradle
RUN cd tmp/app && gradle --no-daemon -i downloadDeps build run jacocoTestReport jacocoToCobertura
COPY init.gradle /root/.gradle/init.gradle
RUN cat ~/.gradle/init.gradle && cd tmp/app && gradle --no-daemon -i --offline build run jacocoTestReport jacocoToCobertura && cat build/reports/cobertura.xml && cd / && rm -rf tmp && mkdir -p tmp

ARG SONAR_VERSION=4.8.1.3023
RUN curl -sL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_VERSION-linux.zip" --output sonar-scanner.zip && unzip -q sonar-scanner.zip && rm -rf sonar-scanner.zip && sed -i "s|use_embedded_jre=true|use_embedded_jre=false|" "/sonar-scanner-$SONAR_VERSION-linux/bin/sonar-scanner" && rm -rf "/sonar-scanner-$SONAR_VERSION-linux/jre" && ln -sf /sonar-scanner-*-linux/bin/* /usr/bin && sonar-scanner -v
