FROM openjdk:8 AS BUILD_IMAGE
RUN apt update && apt install maven -y
copy . .
RUN cd ptmantra-jobs && mvn clean install

FROM tomcat:8-jre11
RUN rm -rf /usr/local/tomcat/webapps/*
#COPY --from=BUILD_IMAGE ptmantra-jobs/target/ptmantra-jobs.jar /usr/local/tomcat/webapps/ptmantra-jobs.jar
COPY --from=BUILD_IMAGE ptmantra-jobs/target/ptmantra-jobs.jar .
EXPOSE 8080
CMD ["catalina.sh", "run"]




--------------------------------------------------------


# Stage 1: Build the Maven project
FROM maven:3.8.3-openjdk-11-slim AS builder

WORKDIR /app

# Copy the Maven project files
COPY ptmantra-jobs .
RUN cd /app/ptmantra-jobs

# Build the project
RUN mvn clean install

# Stage 2: Create a lightweight image and deploy the JAR file
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/ptmantra-jobs/target/ptmantra-jobs.jar .

# Expose the port on which your application runs (if applicable)
EXPOSE 8087

# Run the JAR file
CMD ["java", "-jar", "ptmantra-jobs.jar"]



















