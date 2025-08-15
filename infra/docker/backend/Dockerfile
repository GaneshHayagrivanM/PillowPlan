# Build stage
FROM maven:3.9.8-eclipse-temurin-21 AS build
WORKDIR /app
COPY backend/pom.xml ./backend/pom.xml
RUN --mount=type=cache,target=/root/.m2 mvn -f backend/pom.xml -q -DskipTests dependency:go-offline
COPY backend ./backend
RUN --mount=type=cache,target=/root/.m2 mvn -q -f backend/pom.xml -DskipTests package

# Runtime stage
FROM eclipse-temurin:21-jre
WORKDIR /app
RUN useradd -u 10001 appuser
COPY --from=build /app/backend/target/backend-0.0.1-SNAPSHOT.jar app.jar
USER appuser
EXPOSE 8080
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+UseContainerSupport"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
