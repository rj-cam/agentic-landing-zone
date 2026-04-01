@echo off
setlocal enabledelayedexpansion

echo === Provisioning Workloads ===

set WORKLOADS=01-nonprod 02-prod

for %%W in (%WORKLOADS%) do (
    echo --- %%W ---
    cd /d "%~dp0..\workloads\%%W"
    call terraform init -input=false
    if !ERRORLEVEL! neq 0 (
        echo ERROR: terraform init failed for %%W
        exit /b 1
    )
    call terraform apply -auto-approve -input=false
    if !ERRORLEVEL! neq 0 (
        echo ERROR: terraform apply failed for %%W
        exit /b 1
    )
    echo.
)

echo === Workloads provisioned ===
echo   Non-Prod: http://nonprod.therj.link
echo   Prod:     http://prod.therj.link
