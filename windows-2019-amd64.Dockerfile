FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command"]

RUN iex (iwr 'https://raw.githubusercontent.com/airpwr/airpwr/main/src/install.ps1' -UseBasicParsing)

RUN mkdir -p Temp
COPY pwr.json /Temp/pwr.json
RUN cd Temp; pwr ls -fetch; pwr sh; gradle init --no-daemon -i --type java-application --test-framework junit --dsl groovy --project-name tmp --package tmp --incubating; pwr exit

COPY build.gradle /Temp/app/build.gradle
RUN Push-Location Temp; pwr sh; Push-Location app; gradle --no-daemon -i downloadDeps build run jacocoTestReport spotlessCheck; Pop-Location; pwr exit; Pop-Location; Remove-Item -Path /Temp -Recurse