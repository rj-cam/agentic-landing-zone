@echo off
setlocal enabledelayedexpansion

echo === Provisioning Workloads ===

rem ============================================================================
rem Extract account IDs from 01-organization outputs
rem ============================================================================
echo --- Reading account IDs from organization state ---
cd /d "%~dp0..\foundation\01-organization"
call terraform init -input=false > nul

for /f "tokens=*" %%A in ('terraform output -raw account_id') do set NONPROD_ACCOUNT_ID=%%A
for /f "tokens=*" %%A in ('terraform output -raw account_id') do set PROD_ACCOUNT_ID=%%A

echo   Non-Prod: !NONPROD_ACCOUNT_ID!
echo   Prod:     !PROD_ACCOUNT_ID!
echo.

rem ============================================================================
rem Non-Prod workload
rem ============================================================================
echo --- 01-nonprod ---
cd /d "%~dp0..\workloads\01-nonprod"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 01-nonprod
    exit /b 1
)
call terraform apply -auto-approve -input=false -var="account_id=!NONPROD_ACCOUNT_ID!"
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 01-nonprod
    exit /b 1
)
echo.

rem ============================================================================
rem Prod workload
rem ============================================================================
echo --- 02-prod ---
cd /d "%~dp0..\workloads\02-prod"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 02-prod
    exit /b 1
)
call terraform apply -auto-approve -input=false -var="account_id=!PROD_ACCOUNT_ID!"
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 02-prod
    exit /b 1
)
echo.

echo === Workloads provisioned ===
echo   Non-Prod: https://nonprod.therj.link
echo   Prod:     https://prod.therj.link
