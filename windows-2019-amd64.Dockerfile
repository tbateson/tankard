FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command"]

RUN iex (iwr 'https://raw.githubusercontent.com/airpwr/airpwr/main/src/install.ps1' -UseBasicParsing)

RUN mkdir -p Temp
COPY pwr.json /Temp/pwr.json
RUN cd Temp; pwr version; pwr ls -fetch; pwr -run gradle-init; pwr -run md2pdf-install

COPY build.gradle /Temp/app/build.gradle
RUN cd Temp/app; pwr -run gradle-deps; cd /; Remove-Item -Path /Temp -Recurse