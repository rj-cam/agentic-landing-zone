@echo off
setlocal enabledelayedexpansion

echo === Provisioning Foundation Layers ===
call terraform version
echo.

rem ============================================================================
rem Layer 01 - Organization (creates accounts, no extra vars needed)
rem ============================================================================
echo --- 01-organization ---
cd /d "%~dp0..\foundation\01-organization"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 01-organization
    exit /b 1
)
call terraform apply -auto-approve -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 01-organization
    exit /b 1
)
echo.

rem ============================================================================
rem Extract account IDs from 01-organization outputs
rem ============================================================================
echo --- Extracting account IDs from organization outputs ---

for /f "tokens=*" %%A in ('terraform output -raw log_archive_account_id') do set LOG_ARCHIVE_ACCOUNT_ID=%%A
for /f "tokens=*" %%A in ('terraform output -raw shared_services_account_id') do set SHARED_SERVICES_ACCOUNT_ID=%%A
for /f "tokens=*" %%A in ('terraform output -raw nonprod_account_id') do set NONPROD_ACCOUNT_ID=%%A
for /f "tokens=*" %%A in ('terraform output -raw prod_account_id') do set PROD_ACCOUNT_ID=%%A

echo   Log Archive:     !LOG_ARCHIVE_ACCOUNT_ID!
echo   Shared Services: !SHARED_SERVICES_ACCOUNT_ID!
echo   Non-Prod:        !NONPROD_ACCOUNT_ID!
echo   Prod:            !PROD_ACCOUNT_ID!
echo.

rem ============================================================================
rem Layer 02 - SCPs (uses remote state, no account ID vars needed)
rem ============================================================================
echo --- 02-scps ---
cd /d "%~dp0..\foundation\02-scps"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 02-scps
    exit /b 1
)
call terraform apply -auto-approve -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 02-scps
    exit /b 1
)
echo.

rem ============================================================================
rem Layer 03 - Identity Center (uses remote state, no account ID vars needed)
rem ============================================================================
echo --- 03-identity-center ---
cd /d "%~dp0..\foundation\03-identity-center"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 03-identity-center
    exit /b 1
)
call terraform apply -auto-approve -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 03-identity-center
    exit /b 1
)
echo.

rem ============================================================================
rem Layer 04 - Logging (needs log_archive_account_id for provider)
rem ============================================================================
echo --- 04-logging ---
cd /d "%~dp0..\foundation\04-logging"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 04-logging
    exit /b 1
)
call terraform apply -auto-approve -input=false -var="log_archive_account_id=!LOG_ARCHIVE_ACCOUNT_ID!"
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 04-logging
    exit /b 1
)
echo.

rem ============================================================================
rem Layer 05 - Networking (needs shared_services_account_id for provider)
rem ============================================================================
echo --- 05-networking ---
cd /d "%~dp0..\foundation\05-networking"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 05-networking
    exit /b 1
)
call terraform apply -auto-approve -input=false -var="shared_services_account_id=!SHARED_SERVICES_ACCOUNT_ID!"
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 05-networking
    exit /b 1
)
echo.

rem ============================================================================
rem Layer 06 - Shared Services (needs shared_services_account_id for provider)
rem ============================================================================
echo --- 06-shared-services ---
cd /d "%~dp0..\foundation\06-shared-services"
call terraform init -input=false
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform init failed for 06-shared-services
    exit /b 1
)
call terraform apply -auto-approve -input=false -var="shared_services_account_id=!SHARED_SERVICES_ACCOUNT_ID!"
if !ERRORLEVEL! neq 0 (
    echo ERROR: terraform apply failed for 06-shared-services
    exit /b 1
)
echo.

echo === Foundation provisioned ===
echo.
echo Account IDs (save these for workload provisioning):
echo   LOG_ARCHIVE_ACCOUNT_ID=!LOG_ARCHIVE_ACCOUNT_ID!
echo   SHARED_SERVICES_ACCOUNT_ID=!SHARED_SERVICES_ACCOUNT_ID!
echo   NONPROD_ACCOUNT_ID=!NONPROD_ACCOUNT_ID!
echo   PROD_ACCOUNT_ID=!PROD_ACCOUNT_ID!
echo.
echo Run provision-workloads.bat to deploy services.
