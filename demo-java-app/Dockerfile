FROM adoptopenjdk/maven-openjdk8 as build

COPY pom.xml .
COPY src src

RUN mvn install -DskipTests

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
COPY elastic-apm-agent-1.14.0.jar apm-agent.jar

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -javaagent:apm-agent.jar -jar /app.jar"]
