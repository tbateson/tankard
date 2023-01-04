FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command"]

RUN iex (& "curl.exe" -s --url 'https://raw.githubusercontent.com/airpwr/airpwr/main/src/install.ps1' | Out-String)

RUN mkdir -p Temp
COPY pwr.json /Temp/pwr.json
COPY test.cpp /Temp/test.cpp
RUN cd Temp; pwr version; if ($LASTEXITCODE) { throw }; pwr ls -fetch; if ($LASTEXITCODE) { throw }; pwr fetch; if ($LASTEXITCODE) { throw }; pwr -run gradle-init; if ($LASTEXITCODE) { throw }; pwr -run test-cpp; if ($LASTEXITCODE) { throw }
RUN echo 'org.gradle.cache.cleanup=false' >> ~/.gradle/gradle.properties

COPY build.gradle /Temp/app/build.gradle
RUN cd Temp/app; pwr -run gradle-deps; if ($LASTEXITCODE) { throw }; cd /; Remove-Item -Path /Temp -Recurse