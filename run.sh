#!/bin/bash

cd /home/ec2-user/app

# Check if CodeDeploy environment file exists
ENV_FILE="./codedeploy_env.sh"

if [ -f "$ENV_FILE" ]; then
    echo "Sourcing CodeDeploy environment variables from $ENV_FILE..."
    source "$ENV_FILE"
else
    echo "No CodeDeploy environment file found at $ENV_FILE"
fi

# Find the JAR file (the one CodeBuild packaged)
JAR_FILE=$(ls *.jar | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo "ERROR: No JAR file found!"
    exit 1
fi

echo "Starting Spring Boot application using $JAR_FILE..."

# Run the Spring Boot application
nohup java -jar "$JAR_FILE" > app.log 2>&1 &
