FROM openjdk:17.0.2-jdk-oracle
EXPOSE 8585:8585
ARG JAR_FILE=target/*.jar
COPY target/eureka-server-0.0.1-SNAPSHOT.jar /app/apieurekaserver.jar
ENTRYPOINT ["java", "-jar", "/app/apieurekaserver.jar"]