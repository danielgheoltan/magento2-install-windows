@echo off
cls
setlocal enableDelayedExpansion

:: ----------------------------------------------------------------------------

call config

:: ----------------------------------------------------------------------------
:: Database Setup

mysql -u !MYSQL_USERNAME! -p!MYSQL_PASSWORD! -e ^
    "DROP DATABASE IF EXISTS `!MYSQL_DATABASE!`; CREATE DATABASE `!MYSQL_DATABASE!`;"

:: ---------------------------------------------------------------------------
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
    --use-rewrites=1

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
:: The End - Miscellaneous Commands
