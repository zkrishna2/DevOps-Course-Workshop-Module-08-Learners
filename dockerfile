FROM mcr.microsoft.com/dotnet/sdk:5.0
RUN apt-get update
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

WORKDIR /MyApp
COPY . /MyApp
RUN dotnet build

WORKDIR /MyApp/DotnetTemplate.Web/
RUN npm install
RUN npm run build

CMD [ "dotnet", "run" ]
