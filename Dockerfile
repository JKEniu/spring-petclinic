FROM gradle:latest AS builder
COPY . /app
WORKDIR /app
RUN ./gradlew clean build


FROM openjdk:19-alpine
COPY --from=builder /app/build/libs/*.jar /app/app.jar
WORKDIR /app


EXPOSE 8080


CMD ["java", "-jar", "app.jar"]