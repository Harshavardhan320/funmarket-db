########################
# STAGE 1: BUILD STAGE #
########################
FROM maven:3.9.9-eclipse-temurin-21 AS builder

# Set working directory
WORKDIR /app

# Copy Maven files first for dependency caching
COPY pom.xml .
COPY settings.xml /root/.m2/settings.xml

# Pre-download dependencies (speeds up builds)
RUN mvn dependency:go-offline -s /root/.m2/settings.xml

# Copy the entire source code
COPY src ./src

# Build the application (skip tests for speed)
RUN mvn clean package -DskipTests -s /root/.m2/settings.xml


###########################
# STAGE 2: RUNTIME STAGE  #
###########################
FROM eclipse-temurin:21-jdk-alpine

# Set working directory
WORKDIR /usr/app

# Copy only the final JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose your application port
EXPOSE 8080

# Optional: set Spring Boot profile
ENV SPRING_PROFILES_ACTIVE=prod

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
