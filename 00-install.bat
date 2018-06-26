@echo off
cls
setlocal enableDelayedExpansion

:: ----------------------------------------------------------------------------

call config
set INSTALL_PATH=%~dp0

:: ----------------------------------------------------------------------------

for /f "skip=1" %%x in ('wmic os get LocalDateTime') do (
    if not defined TIMESTAMP set TIMESTAMP=%%x
)

for %%i in ("!PROJECT_PATH!") do (
    set PROJECT_FOLDER=%%~ni
)

:: ---------------------------------------------------------------------------
:: Folders Setup

if exist "!PROJECT_PATH!" (
    rename "!PROJECT_PATH!" "!PROJECT_FOLDER!_!TIMESTAMP:~0,14!"
)

if not exist "!PROJECT_PATH!" (
    mkdir "!PROJECT_PATH!"
)

cd /d "!PROJECT_PATH!"

:: ---------------------------------------------------------------------------
:: Hosts Setup

call "!INSTALL_PATH!src/util/hosts" add "!PROJECT_HOST!"
call "!INSTALL_PATH!src/util/hosts" format

:: ---------------------------------------------------------------------------
:: Database Setup

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "DROP DATABASE IF EXISTS `!MYSQL_DATABASE!`; CREATE DATABASE `!MYSQL_DATABASE!`;"

:: ---------------------------------------------------------------------------
:: Magento Setup

cd /d "!PROJECT_PATH!"

call composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition .

php bin/magento setup:install ^
    --db-host="!MYSQL_HOST!" ^
    --db-name="!MYSQL_DATABASE!" ^
    --db-user="!MYSQL_USERNAME!" ^
    --db-password="!MYSQL_PASSWORD!" ^
    --base-url="!MAGENTO_BASE_URL!" ^
    --backend-frontname="!MAGENTO_BACKEND_FRONTNAME!" ^
    --admin-user="!MAGENTO_ADMIN_USER!" ^
    --admin-password="!MAGENTO_ADMIN_PASSWORD!" ^
    --admin-firstname="!MAGENTO_ADMIN_FIRSTNAME!" ^
    --admin-lastname="!MAGENTO_ADMIN_LASTNAME!" ^
    --admin-email="!MAGENTO_ADMIN_EMAIL!" ^
    --use-rewrites=1

copy "!INSTALL_PATH!src\magento\auth.json" "!PROJECT_PATH!"

:: ---------------------------------------------------------------------------
:: Set Developer Mode

php bin/magento deploy:mode:set developer

:: ---------------------------------------------------------------------------
:: Change Uniform Resource Identifier (URI) to access the Magento Admin

REM php bin/magento setup:config:set --no-interaction --backend-frontname=!MAGENTO_ADMIN_URL!

:: ---------------------------------------------------------------------------
:: Disable some cache types

php bin/magento cache:disable layout block_html full_page translate

:: ---------------------------------------------------------------------------
:: Set Session Lifetime

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'admin/security/session_lifetime', 604800) ON DUPLICATE KEY UPDATE `value` = 604800;"

:: ---------------------------------------------------------------------------
:: Disable Sign Static Files

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'dev/static/sign', 0) ON DUPLICATE KEY UPDATE `value` = 0;"

:: ---------------------------------------------------------------------------
:: Allow Symlinks

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'dev/template/allow_symlink', 1) ON DUPLICATE KEY UPDATE `value` = 1;"

:: ---------------------------------------------------------------------------
:: Disable WYSIWYG Editor by Default

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'cms/wysiwyg/enabled', 'hidden') ON DUPLICATE KEY UPDATE `value` = 'hidden';"
    
:: ---------------------------------------------------------------------------
:: Set Admin Startup Page

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'admin/startup/menu_item_id', 'Magento_Config::system_config') ON DUPLICATE KEY UPDATE `value` = 'Magento_Config::system_config';"

:: ---------------------------------------------------------------------------
:: Disable Admin Notifications
:: TODO

:: ---------------------------------------------------------------------------
:: Grunt Setup

cd /d "!PROJECT_PATH!"

rename Gruntfile.js.sample Gruntfile.js
rename grunt-config.json.sample grunt-config.json
rename package.json.sample package.json

copy /y "!INSTALL_PATH!\src\magento\local-themes.js" "!PROJECT_PATH!\dev\tools\grunt\configs\local-themes.js"

call npm install

:: ---------------------------------------------------------------------------
:: Create Symlinks

call mklink /j "!SYMLINK!" "!PROJECT_PATH!"
call mklink "!PROJECT_PATH!/deploy" "!INSTALL_PATH!src\magento\deploy"
call mklink "!PROJECT_PATH!/deploy.bat" "!INSTALL_PATH!src\magento\deploy.bat"
call mklink "!PROJECT_PATH!/deploy-frontend.bat" "!INSTALL_PATH!src\magento\deploy-frontend.bat"
call mklink "!PROJECT_PATH!/deploy-backend.bat" "!INSTALL_PATH!src\magento\deploy-backend.bat"
call mklink "!PROJECT_PATH!/deploy-theme.bat" "!INSTALL_PATH!src\magento\deploy-theme.bat"
call mklink "!PROJECT_PATH!/deploy-theme-blank.bat" "!INSTALL_PATH!src\magento\deploy-theme-blank.bat"
call mklink "!PROJECT_PATH!/deploy-theme-luma.bat" "!INSTALL_PATH!src\magento\deploy-theme-luma.bat"
call mklink "!PROJECT_PATH!/di.bat" "!INSTALL_PATH!src\magento\di.bat"
call mklink "!PROJECT_PATH!/grunt-theme.bat" "!INSTALL_PATH!src\magento\grunt-theme.bat"
call mklink "!PROJECT_PATH!/grunt-theme-blank.bat" "!INSTALL_PATH!src\magento\grunt-theme-blank.bat"
call mklink "!PROJECT_PATH!/grunt-theme-luma.bat" "!INSTALL_PATH!src\magento\grunt-theme-luma.bat"

:: ---------------------------------------------------------------------------
:: The End - Miscellaneous Commands
