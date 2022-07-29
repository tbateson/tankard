FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command"]

RUN iex (iwr 'https://raw.githubusercontent.com/airpwr/airpwr/main/src/install.ps1' -UseBasicParsing)

RUN mkdir -p Temp
COPY pwr.json /Temp/pwr.json
COPY build.gradle /Temp/build.gradle

RUN pwr ls -fetch; Push-Location Temp; pwr sh; gradle --no-daemon downloadDeps; pwr exit; Pop-Location; Remove-Item -Path /Temp -Recurse