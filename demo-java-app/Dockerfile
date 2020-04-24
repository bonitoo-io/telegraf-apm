FROM openjdk:8-jdk-alpine as build
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
RUN ./mvnw install

FROM openjdk:8-jdk-alpine
COPY --from=build  /workspace/app/target/*.jar /app.jar
COPY elastic-apm-agent-1.14.0.jar apm-agent.jar

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -javaagent:apm-agent.jar -jar /app.jar"]
