
# Java 21 runtime
FROM eclipse-temurin:21-jre

# Application directory
WORKDIR /app

# Copy Maven-built JAR
COPY target/*.jar app.jar

# Application port
EXPOSE 8080

# Start application
ENTRYPOINT ["java", "-jar", "app.jar"]


