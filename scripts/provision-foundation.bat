@echo off
setlocal enabledelayedexpansion

echo === Provisioning Foundation Layers ===
call terraform version
echo.

set LAYERS=01-organization 02-scps 03-identity-center 04-logging 05-networking 06-shared-services

for %%L in (%LAYERS%) do (
    echo --- %%L ---
    cd /d "%~dp0..\foundation\%%L"
    call terraform init -input=false
    if !ERRORLEVEL! neq 0 (
        echo ERROR: terraform init failed for %%L
        exit /b 1
    )
    call terraform apply -auto-approve -input=false
    if !ERRORLEVEL! neq 0 (
        echo ERROR: terraform apply failed for %%L
        exit /b 1
    )
    echo.
)

echo === Foundation provisioned ===
echo Run provision-workloads.bat to deploy services.
