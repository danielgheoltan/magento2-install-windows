@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

:: Enable maintenance mode
CALL php bin/magento maintenance:enable

:: Cleanup
CALL :deleteFolder "generated"
CALL :deleteFolder "pub/static/adminhtml"
CALL :deleteFolder "pub/static/frontend"
CALL :deleteFolder "var/cache"
CALL :deleteFolder "var/page_cache"
CALL :deleteFolder "var/view_preprocessed"

:: Flush cache
CALL php bin/magento cache:flush

:: Update required components
CALL composer update

:: Run setup scripts
CALL php bin/magento setup:db-data:upgrade
CALL php bin/magento setup:db-schema:upgrade

:: Compile code
CALL php bin/magento setup:di:compile

:: Reindex
CALL php bin/magento indexer:reindex

:: Resize images
CALL php bin/magento catalog:images:resize

:: Set themes as physical
CALL php bin/magento mindmagnet-util:set-themes

:: Deploy static view files
CALL php bin/magento setup:static-content:deploy en_US --no-html-minify -f

:: Disable maintenance mode
CALL php bin/magento maintenance:disable

:: ----------------------------------------------------------------------------

:: Force execution to quit at the end of the "main" logic
EXIT /B %ERRORLEVEL%

:: ----------------------------------------------------------------------------
:: Functions
:: ----------------------------------------------------------------------------

:deleteFolder
IF EXIST "%~1" (
    RMDIR /s /q "%~1";
)

ECHO "%~1" has been deleted.

EXIT /B 0
