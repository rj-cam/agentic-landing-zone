@echo off
setlocal enabledelayedexpansion

echo === Tearing Down Workloads ===
echo WARNING: This will destroy all workload infrastructure.
echo.

set WORKLOADS=02-prod 01-nonprod

for %%W in (%WORKLOADS%) do (
    echo --- Destroying %%W ---
    cd /d "%~dp0..\workloads\%%W"
    call terraform init -input=false
    if !ERRORLEVEL! neq 0 (
        echo ERROR: terraform init failed for %%W
        exit /b 1
    )
    call terraform destroy -auto-approve -input=false
    if !ERRORLEVEL! neq 0 (
        echo ERROR: terraform destroy failed for %%W
        exit /b 1
    )
    echo.
)

echo === Workloads destroyed. Foundation intact. ===
