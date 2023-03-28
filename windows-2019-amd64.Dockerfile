FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command"]

RUN Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force
RUN Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN Install-Module Airpower -Scope AllUsers
RUN air version
RUN $ProgressPreference = 'SilentlyContinue'; air pull 'jdk:11', 'gradle', 'vs-buildtools', 'llvm', 'git', 'node'
RUN air exec 'git' -ScriptBlock { git config --system --add safe.directory '*' }

RUN mkdir -p Temp
COPY test.cpp /Temp/test.cpp
RUN cd /Temp; air exec 'vs-buildtools::msvc143-amd64', 'llvm' -ScriptBlock { clang-cl test.cpp }; ./test.exe
RUN cd /Temp; air exec 'jdk:11', 'gradle' -ScriptBlock { gradle init --no-daemon -i --type java-application --test-framework junit --dsl groovy --project-name tmp --package tmp --incubating }
COPY build.gradle /Temp/app/build.gradle
RUN cd Temp/app; air exec 'jdk:11', 'gradle' -ScriptBlock { gradle --no-daemon -i downloadDeps build run jacocoTestReport jacocoToCobertura }
COPY init.gradle /Users/ContainerAdministrator/.gradle/init.gradle
RUN cd Temp/app; air exec 'jdk:11', 'gradle' -ScriptBlock { gradle --no-daemon -i --offline build run jacocoTestReport jacocoToCobertura }
RUN Get-Item /Temp/app/build/reports/cobertura.xml
RUN Remove-Item -Path /Temp -Recurse
