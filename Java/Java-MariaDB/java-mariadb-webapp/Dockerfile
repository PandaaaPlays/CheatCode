# Use Maven to build the application
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Use OpenJDK to run the app
#ARG UDES_JAVA_VERSION=17.0.12.7.1-1
#FROM repo-docker.outils.sti.usherbrooke.ca/udes-java:${UDES_JAVA_VERSION}
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/java-mariadb-webapp-0.0.1-SNAPSHOT.jar app.jar

# Exposer le port 8080
EXPOSE 8080

# Rouler l'application Springboot
ENTRYPOINT ["java", "-jar", "app.jar"]