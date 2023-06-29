FROM gradle:latest AS builder
COPY /src /app/src
COPY /gradle /app/gradle
COPY build.gradle gradlew settings.gradle /app/
WORKDIR /app
RUN ./gradlew clean build


FROM openjdk:19-jre-slim
COPY --from=builder /app/build/libs/spring-petclinic-3.1.0.jar /app/app.jar
WORKDIR /app


EXPOSE 8080


CMD ["java", "-jar", "app.jar"]
