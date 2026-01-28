# Stage 1: Build the application (Multi-stage build)
FROM maven:3.8-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
# Cache dependencies to speed up subsequent builds
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Final Runtime Image
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# 1. Best Practice: Install minimal dependencies for Healthcheck & Security
# We need 'curl' for the HEALTHCHECK and 'ca-certificates' for New Relic SSL
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Best Practice: Create a non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup -u 1001 appuser

# 3. New Relic Integration
# Download the agent and create a logs directory with correct permissions
RUN mkdir -p /app/newrelic/logs && \
    chown -r appuser:appgroup /app/newrelic
    
ADD https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic.jar /app/newrelic/newrelic.jar
# Note: You can also COPY a custom newrelic.yml if you have specific local configs
ADD https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic.yml /app/newrelic/newrelic.yml

# 4. Copy the JAR from the build stage
COPY --from=build /app/target/*.jar app.jar
RUN chown appuser:appgroup app.jar

# 5. Requirement: Health Check configuration
# Uses the standard Spring Boot Actuator endpoint (port 8080)
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# 6. Switch to non-root user
USER 1001

# 7. Start the application with New Relic Agent
# We use the -javaagent flag and pass the app name via Env Var in ECS
ENTRYPOINT ["java", \
            "-javaagent:/app/newrelic/newrelic.jar", \
            "-Dnewrelic.config.app_name=${NEW_RELIC_APP_NAME}", \
            "-jar", "app.jar"]