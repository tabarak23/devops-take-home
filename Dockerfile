#main stage
#using maven an jdk to compile the java app
#choosing multi stage build keeps the final image size small and secure
FROM maven:3.9.6-eclipse-temurin-17 AS foundation

# sets working directory
WORKDIR /app 


#copying pom first for layer caching which allows to cache dependencies if pom is unchanged
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn dependency:resolve


# copying application code
COPY src ./src


#building the app and skipped the tests to make ci fast
RUN --mount=type=cache,target=/root/.m2 \
    mvn clean package -DskipTests

RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*


RUN curl -L https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip \
  -o /tmp/newrelic.zip && \
  unzip /tmp/newrelic.zip -d /app && \
  rm /tmp/newrelic.zip    
# last stage
#lightweight jre image to run the app
#could have used distrolesss but health check would break coz it doesnt support shell annd pacakage managers
#alpine reduces image size and still supports shell commands
FROM eclipse-temurin:17-jre-alpine 


#creating non root user for security 
RUN addgroup -S tabarak && adduser -S tabarak -G tabarak


#switching to non root user
USER tabarak
WORKDIR /app


#copying alreadu built jar file from foundation stage
#keeps run time image small
COPY --from=foundation /app/target/*.jar mal_ai.jar
COPY --from=foundation /app/newrelic /app/newrelic


#expose app port
EXPOSE 8080


#health check to see app is running properly
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s \
  CMD wget -qO- http://localhost:8080/health || exit 1


#strating the app
ENTRYPOINT ["java","-javaagent:/app/newrelic/newrelic.jar","-Dnewrelic.config.agent_enabled=true","-jar","mal_ai.jar"]
