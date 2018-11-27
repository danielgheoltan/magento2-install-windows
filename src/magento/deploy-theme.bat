@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

CALL :deleteFolder "pub/static/frontend/%2"
CALL :deleteFolder "var/cache"
CALL :deleteFolder "var/page_cache"
CALL :deleteFolder "var/view_preprocessed"

CALL grunt exec:%1
CALL php bin/magento setup:static-content:deploy en_US --theme="%2" --no-html-minify -f
CALL grunt less:%1 & grunt watch less:%1

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
