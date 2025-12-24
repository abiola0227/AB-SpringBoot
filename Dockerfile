FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copy the Spring Boot JAR into the container
COPY build/libs/*.jar app.jar

# Expose Spring Boot's default port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
