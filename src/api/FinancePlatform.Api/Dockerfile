# Stage 1: build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /build

# Copy project files first and restore dependencies
# Copying these before source code lets Docker cache the restore layer.
# If source changes but .csproj doesn't, the restore layer is reused.
COPY src/api/FinancePlatform.Api/FinancePlatform.Api.csproj \
     src/api/FinancePlatform.Api/
COPY src/api/FinancePlatform.Api.Tests/FinancePlatform.Api.Tests.csproj \
     src/api/FinancePlatform.Api.Tests/
COPY FinancePlatform.slnx .

RUN dotnet restore FinancePlatform.slnx

# Copy the rest of the source
COPY src/api/ src/api/

# Publish the API
RUN dotnet publish src/api/FinancePlatform.Api \
    --no-restore \
    --configuration Release \
    --output /app/publish

# Stage 2: runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080

EXPOSE 8080

ENTRYPOINT ["dotnet", "FinancePlatform.Api.dll"]