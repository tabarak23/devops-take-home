# Stage 1: Build the application
FROM maven:3.8-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Final Runtime Image
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# 1. System dependencies
RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

# 2. Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup -u 1001 appuser

# 3. New Relic Integration
RUN mkdir -p /app/newrelic/logs && chown -R appuser:appgroup /app/newrelic

# DOWNLOAD ONLY THE JAR. (DO NOT ADD THE .YML FILE)
ADD --chown=appuser:appgroup https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic.jar /app/newrelic/newrelic.jar

# 4. Copy Application JAR
COPY --from=build --chown=appuser:appgroup /app/target/*.jar /app/app.jar

# 5. Permissions
RUN chmod -R 755 /app/newrelic

# 6. Health Check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# 7. Security: Switch to non-root
USER 1001

# 8. Start Application
# We pass the license key and app name as system properties.
# This works perfectly even without a newrelic.yml file.

ENTRYPOINT ["sh", "-c", " \
    CLEAN_KEY=$(echo $NEW_RELIC_LICENSE_KEY | sed -E 's/.*\"NEW_RELIC_LICENSE_KEY\":\"([^\"]+)\".*/\1/') && \
    if [ \"$CLEAN_KEY\" = \"$NEW_RELIC_LICENSE_KEY\" ]; then CLEAN_KEY=$NEW_RELIC_LICENSE_KEY; fi && \
    java -javaagent:/app/newrelic/newrelic.jar \
    -Dnewrelic.config.license_key=$CLEAN_KEY \
    -Dnewrelic.config.app_name=${NEW_RELIC_APP_NAME} \
    -jar app.jar"]