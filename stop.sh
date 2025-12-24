#!/bin/bash

echo "Stopping Spring Boot application..."

# Find any running Spring Boot JAR process
PID=$(pgrep -f "java -jar")

if [ -z "$PID" ]; then
    echo "No Spring Boot process found."
else
    echo "Killing process $PID"
    kill -9 $PID
fi
