# Use OpenJDK 17 as base image
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY target/todoapp-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
