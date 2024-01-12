FROM openjdk:17.0.2-jdk-oracle
EXPOSE 8080:8080
ARG JAR_FILE=target/*.jar
COPY target/appreciclagem-0.0.1-SNAPSHOT.jar /app/apireciclagem.jar
ENTRYPOINT ["java", "-jar", "/app/apireciclagem.jar"]