# AB-SpringBoot

CI/CD pipeline for a Spring Boot application — Gradle build, a custom Docker-enabled CodeBuild image, and automated deployment to AWS.

## Overview

This project automates the build and deployment of a Spring Boot application through a full CI/CD pipeline: Gradle compiles and packages the application into a runnable JAR, a Dockerfile containerizes it, and a custom CodeBuild image (based on Amazon Linux 2, with Docker installed) enables CodeBuild to build and push container images — something CodeBuild can't do in its default, unprivileged environment.

## Pipeline Stages

1. **Build** — Gradle compiles the Spring Boot application and packages it into a runnable JAR (`build/libs/`), bundling all dependencies (Spring MVC, Jackson, an embedded Tomcat server) into a single deployable artifact.
2. **Containerize** — A `Dockerfile` builds a lightweight image (Java 17) around the JAR, exposing port 8080.
3. **Custom Build Environment** — A second Dockerfile defines the CodeBuild environment itself (Amazon Linux 2 + Docker installed), giving CodeBuild the ability to build Docker images, run containers, and push to Amazon ECR — capabilities not available in CodeBuild's default sandboxed environment.
4. **CI Pipeline** — `buildspec.yml` defines the CodeBuild phases (install, pre-build, build, post-build) that compile, containerize, and push the image to ECR.
5. **Deployment** — `appspec.yml` and lifecycle hook scripts (`run.sh`, `stop.sh`, `validate.sh`) define the deployment behavior for AWS CodeDeploy, supporting deployment targets including ECS Fargate, ECS on EC2, EC2 with CodeDeploy, or Lambda (via container).

## Repo Contents

| File/Folder | Purpose |
|---|---|
| `src/` | Spring Boot application source |
| `build.gradle`, `settings.gradle`, `gradlew` | Gradle build configuration and wrapper |
| `Dockerfile` | Containerizes the built Spring Boot JAR |
| `buildspec.yml` | AWS CodeBuild pipeline definition |
| `appspec.yml` | AWS CodeDeploy deployment specification |
| `run.sh` / `stop.sh` / `validate.sh` | CodeDeploy lifecycle hook scripts |

## Tech Stack

Spring Boot · Gradle · Docker · AWS CodeBuild · AWS CodeDeploy · Amazon ECR · Amazon ECS Fargate
