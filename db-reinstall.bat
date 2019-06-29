@echo off
cls
setlocal enableDelayedExpansion

:: ----------------------------------------------------------------------------

call config

:: ----------------------------------------------------------------------------
:: Database Setup

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "DROP DATABASE IF EXISTS `!MYSQL_DATABASE!`; CREATE DATABASE `!MYSQL_DATABASE!`;"

:: ----------------------------------------------------------------------------
:: Magento Setup

cd /d "!PROJECT_PATH!"

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

php bin/magento config:set admin/security/session_lifetime 604800

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
:: Set Admin Startup Page

php bin/magento config:set admin/startup/menu_item_id Magento_Config::system_config

:: ----------------------------------------------------------------------------
:: The End - Miscellaneous Commands
