@echo off
cls
setlocal enableDelayedExpansion

:: ----------------------------------------------------------------------------

call config

:: ----------------------------------------------------------------------------
:: Variables

set INSTALL_PATH=%~dp0

set TIMESTAMP=
for /f "skip=1" %%x in ('wmic os get LocalDateTime') do (
    if not defined TIMESTAMP (
        set TIMESTAMP=%%x
        set TIMESTAMP=!TIMESTAMP:~0,14!
    )
)

for %%i in ("!PROJECT_PATH!") do (
    set PROJECT_FOLDER=%%~ni
)

set DATABASE=
for /f %%i in ('mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e "SHOW DATABASES LIKE '!MYSQL_DATABASE!'"') do (
    set DATABASE=%%i
)

:: ----------------------------------------------------------------------------
:: Folders Setup

if exist "!PROJECT_PATH!" (
    rename "!PROJECT_PATH!" "!PROJECT_FOLDER!_!TIMESTAMP!"
)

if not exist "!PROJECT_PATH!" (
    mkdir "!PROJECT_PATH!"
)

:: ----------------------------------------------------------------------------
:: Database Setup

if defined DATABASE (
    mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
        "CREATE DATABASE `!MYSQL_DATABASE!_!TIMESTAMP!`;"

    mysqldump -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! !MYSQL_DATABASE! | mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -D !MYSQL_DATABASE!_!TIMESTAMP!
)

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "DROP DATABASE IF EXISTS `!MYSQL_DATABASE!`; CREATE DATABASE `!MYSQL_DATABASE!`;"

:: ----------------------------------------------------------------------------
:: Magento Setup

cd /d "!PROJECT_PATH!"

set COMPOSER_AUTH={"http-basic": {"repo.magento.com": {"username": "!MAGENTO_PUBLIC_KEY!", "password": "!MAGENTO_PRIVATE_KEY!"}}}

if "%1"=="" (
    call composer create-project --repository=https://repo.magento.com/ magento/project-community-edition .
) else (
    call composer create-project --repository=https://repo.magento.com/ magento/project-community-edition=%1 .
)

echo !COMPOSER_AUTH! > auth.json

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
    --language="!MAGENTO_LANGUAGE!" ^
    --currency="!MAGENTO_CURRENCY!" ^
    --timezone="!MAGENTO_TIMEZONE!" ^
    --use-rewrites=1

:: ----------------------------------------------------------------------------
:: Set Developer Mode

php bin/magento deploy:mode:set developer

:: ----------------------------------------------------------------------------
:: Disable Some Cache Types

php bin/magento cache:disable layout block_html full_page translate

:: ----------------------------------------------------------------------------
:: Set Session Lifetime

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'admin/security/session_lifetime', 604800) ON DUPLICATE KEY UPDATE `value` = 604800;"

:: ----------------------------------------------------------------------------
:: Disable Sign Static Files

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'dev/static/sign', 0) ON DUPLICATE KEY UPDATE `value` = 0;"

:: ----------------------------------------------------------------------------
:: Allow Symlinks

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'dev/template/allow_symlink', 1) ON DUPLICATE KEY UPDATE `value` = 1;"

:: ----------------------------------------------------------------------------
:: Disable WYSIWYG Editor by Default

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'cms/wysiwyg/enabled', 'hidden') ON DUPLICATE KEY UPDATE `value` = 'hidden';"

:: ----------------------------------------------------------------------------
:: Set Admin Startup Page

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "USE `!MYSQL_DATABASE!`; INSERT INTO `core_config_data` (scope, scope_id, path, value) VALUES ('default', 0, 'admin/startup/menu_item_id', 'Magento_Config::system_config') ON DUPLICATE KEY UPDATE `value` = 'Magento_Config::system_config';"

:: ----------------------------------------------------------------------------
:: Grunt Setup

cd /d "!PROJECT_PATH!"

rename Gruntfile.js.sample      Gruntfile.js
rename grunt-config.json.sample grunt-config.json
rename package.json.sample      package.json

copy /y "!INSTALL_PATH!\src\magento\dev\tools\grunt\configs\local-themes.js" "!PROJECT_PATH!\dev\tools\grunt\configs\local-themes.js"

call npm install

:: ----------------------------------------------------------------------------
:: Copy Batch Files

copy "!INSTALL_PATH!src\magento\deploy.bat"             "!PROJECT_PATH!/deploy.bat"
copy "!INSTALL_PATH!src\magento\deploy-backend.bat"     "!PROJECT_PATH!/deploy-backend.bat"
copy "!INSTALL_PATH!src\magento\deploy-frontend.bat"    "!PROJECT_PATH!/deploy-frontend.bat"
copy "!INSTALL_PATH!src\magento\deploy-theme.bat"       "!PROJECT_PATH!/deploy-theme.bat"
copy "!INSTALL_PATH!src\magento\deploy-theme-blank.bat" "!PROJECT_PATH!/deploy-theme-blank.bat"
copy "!INSTALL_PATH!src\magento\deploy-theme-luma.bat"  "!PROJECT_PATH!/deploy-theme-luma.bat"
copy "!INSTALL_PATH!src\magento\di.bat"                 "!PROJECT_PATH!/di.bat"
copy "!INSTALL_PATH!src\magento\grunt-theme.bat"        "!PROJECT_PATH!/grunt-theme.bat"
copy "!INSTALL_PATH!src\magento\grunt-theme-blank.bat"  "!PROJECT_PATH!/grunt-theme-blank.bat"
copy "!INSTALL_PATH!src\magento\grunt-theme-luma.bat"   "!PROJECT_PATH!/grunt-theme-luma.bat"

:: ----------------------------------------------------------------------------
:: The End - Miscellaneous Commands
