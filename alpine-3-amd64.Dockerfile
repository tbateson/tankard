FROM amd64/alpine:3

RUN apk update
RUN apk add curl unzip which clang build-base git openjdk11 nodejs npm ttf-freefont nss chromium
RUN git config --system --add safe.directory '*'

ENV CHROME_BIN="/usr/bin/chromium-browser" PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"
RUN mkdir -p tmp
COPY README.md /tmp/README.md
RUN node -v && npm i -g puppeteer && npm i -g md-to-pdf && cd tmp && md-to-pdf README.md --launch-options '{ "executablePath": "/usr/bin/chromium-browser", "args": ["--no-sandbox", "--headless", "--disable-gpu"] }'

ARG GRADLE_VERSION=8.5
RUN curl -sL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" --output gradle.zip && unzip -q gradle.zip && rm -rf gradle.zip && ln -sf /gradle-*/bin/gradle /usr/bin/
RUN mkdir -p /root/.gradle && echo 'org.gradle.cache.cleanup=false' >> /root/.gradle/gradle.properties
RUN cd tmp && gradle init --no-daemon -i --type java-application --test-framework junit --dsl groovy --project-name tmp --package tmp --incubating
COPY build.gradle /tmp/app/build.gradle
RUN cd tmp/app && gradle --no-daemon -i downloadDeps build run jacocoTestReport jacocoToCobertura
COPY init.gradle /root/.gradle/init.gradle
RUN cat ~/.gradle/init.gradle && cd tmp/app && gradle --no-daemon -i --offline build run jacocoTestReport jacocoToCobertura && cat build/reports/cobertura.xml && cd / && rm -rf tmp && mkdir -p tmp

ARG SONAR_VERSION=4.8.1.3023
RUN curl -sL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_VERSION-linux.zip" --output sonar-scanner.zip && unzip -q sonar-scanner.zip && rm -rf sonar-scanner.zip && sed -i "s|use_embedded_jre=true|use_embedded_jre=false|" "/sonar-scanner-$SONAR_VERSION-linux/bin/sonar-scanner" && rm -rf "/sonar-scanner-$SONAR_VERSION-linux/jre" && ln -sf /sonar-scanner-*-linux/bin/* /usr/bin && sonar-scanner -v
