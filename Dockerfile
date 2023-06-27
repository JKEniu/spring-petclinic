# Stage 1: Build the application
FROM gradle:latest AS builder
COPY . /app
WORKDIR /app
RUN ./gradlew clean build

# Stage 2: Create a minimal JRE image
FROM openjdk:19-alpine
COPY --from=builder /app/build/libs/*.jar /app/app.jar
WORKDIR /app

# Expose the port if necessary
EXPOSE 8080

# Define the command to run your application
CMD ["java", "-jar", "app.jar"]