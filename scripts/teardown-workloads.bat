@echo off
setlocal enabledelayedexpansion

echo === Tearing Down Workloads ===
echo WARNING: This will destroy all workload infrastructure.
echo.

rem ============================================================================
rem Extract account IDs from 01-organization outputs
rem ============================================================================
cd /d "%~dp0..\foundation\01-organization"
call terraform init -input=false > nul

for /f "tokens=*" %%A in ('terraform output -raw nonaccount_id') do set NONPROD_ACCOUNT_ID=%%A
for /f "tokens=*" %%A in ('terraform output -raw account_id') do set PROD_ACCOUNT_ID=%%A

rem ============================================================================
rem Destroy in reverse order: prod first, then nonprod
rem ============================================================================
echo --- Destroying 02-prod ---
cd /d "%~dp0..\workloads\02-prod"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 02-prod
    exit /b 1
)
call terraform destroy -auto-approve -input=false -var="account_id=!PROD_ACCOUNT_ID!"
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform destroy failed for 02-prod
    exit /b 1
)
echo.

echo --- Destroying 01-nonprod ---
cd /d "%~dp0..\workloads\01-nonprod"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 01-nonprod
    exit /b 1
)
call terraform destroy -auto-approve -input=false -var="nonaccount_id=!NONPROD_ACCOUNT_ID!"
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform destroy failed for 01-nonprod
    exit /b 1
)
echo.

echo === Workloads destroyed. Foundation intact. ===
