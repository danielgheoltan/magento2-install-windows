@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

:: Enable maintenance mode
CALL php bin/magento maintenance:enable

:: Cleanup
CALL :deleteFolder "generated"
CALL :deleteFolder "pub/static/frontend"
CALL :deleteFolder "var/cache"
CALL :deleteFolder "var/page_cache"
CALL :deleteFolder "var/view_preprocessed"

:: Flush cache
CALL php bin/magento cache:flush

:: Run setup scripts
CALL php bin/magento setup:upgrade

:: Deploy static files
CALL php bin/magento setup:static-content:deploy en_US --area="frontend" --no-html-minify -f

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
    RMDIR /S /Q "%~1";
)

ECHO "%~1" has been deleted.

EXIT /B 0
