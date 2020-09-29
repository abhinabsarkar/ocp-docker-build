FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env

# Set ASPNETCORE_URLS
ENV ASPNETCORE_URLS=https://*:8080

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /app && chmod -R og+rwx /app

# Expose port 8080 for the application.
EXPOSE 8080

# Run container by default as user with id 1001 (default)
#USER 1001

COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "aspnetapp.dll"]