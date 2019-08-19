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
    call composer create-project --repository=https://repo.magento.com/ magento/project-!MAGENTO_EDITION!-edition .
) else (
    call composer create-project --repository=https://repo.magento.com/ magento/project-!MAGENTO_EDITION!-edition=%1 .
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
:: Set Use Form Key

php bin/magento config:set admin/security/use_form_key 0

:: ----------------------------------------------------------------------------
:: Set Session Lifetime

php bin/magento config:set admin/security/session_lifetime 604800

:: ----------------------------------------------------------------------------
:: Set Password Lifetime

php bin/magento config:set admin/security/password_lifetime ''

:: ----------------------------------------------------------------------------
:: Set Password Is Forced

php bin/magento config:set admin/security/password_is_forced 0

:: ----------------------------------------------------------------------------
:: Disable Sign Static Files

php bin/magento config:set dev/static/sign 0

:: ----------------------------------------------------------------------------
:: Allow Symlinks

php bin/magento config:set dev/template/allow_symlink 1

:: ----------------------------------------------------------------------------
:: Disable WYSIWYG Editor by Default

php bin/magento config:set cms/wysiwyg/enabled hidden

:: ----------------------------------------------------------------------------
:: Disable Captcha in Admin

php bin/magento config:set admin/captcha/enable 0

:: ----------------------------------------------------------------------------
:: Set Admin Startup Page

php bin/magento config:set admin/startup/menu_item_id Magento_Config::system_config

:: ----------------------------------------------------------------------------
:: Grunt Setup

cd /d "!PROJECT_PATH!"

rename Gruntfile.js.sample      Gruntfile.js
rename grunt-config.json.sample grunt-config.json
rename package.json.sample      package.json

copy /y "!INSTALL_PATH!\src\magento\dev\tools\grunt\configs\local-themes.js" "!PROJECT_PATH!\dev\tools\grunt\configs\local-themes.js"

call npm install

:: ----------------------------------------------------------------------------
:: The End - Miscellaneous Commands
