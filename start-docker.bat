@echo off
setlocal enabledelayedexpansion

:: Check if Docker is running
docker info > nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

:: Set the working directory
cd /d "%~dp0app\latest"

:: Check if docker-compose.yml exists
if not exist "docker-compose.yml" (
    echo Error: docker-compose.yml not found in app\latest directory
    pause
    exit /b 1
)

:: Run docker-compose up
echo Starting Docker Compose services...
docker-compose up

if %errorlevel% neq 0 (
    echo Error: Failed to start Docker Compose services
    pause
    exit /b 1
)

echo Docker Compose services started successfully
pause