# Use a Maven + OpenJDK 17 image as the base
FROM openjdk:17-jdk-slim AS build

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml (to cache dependencies)
COPY pom.xml .

# Download dependencies (this will be cached)
RUN mvn dependency:go-offline -B

# Copy the application source code
COPY src src

# Build the application
RUN mvn clean package -DskipTests -B

# Create the final image
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]