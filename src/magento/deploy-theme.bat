@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

SET THEME=%1
SET LOCALE=%2
SET GRUNT_THEME=%3

:: ----------------------------------------------------------------------------

CALL :deleteFolder "pub/static/frontend/%THEME%/%LOCALE%"
CALL :deleteFolder "var/cache"
CALL :deleteFolder "var/page_cache"
CALL :deleteFolder "var/view_preprocessed/less/frontend/%THEME%/%LOCALE%"
CALL :deleteFolder "var/view_preprocessed/pub/static/frontend/%THEME%/%LOCALE%"
CALL :deleteFolder "var/view_preprocessed/source/frontend/%THEME%/%LOCALE%"
ECHO.

:: ----------------------------------------------------------------------------

CALL grunt exec:%GRUNT_THEME%
CALL php bin/magento setup:static-content:deploy %LOCALE% --theme="%THEME%" --no-html-minify -f
CALL grunt watch less:%GRUNT_THEME%

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

:: ----------------------------------------------------------------------------

:deleteFile
IF EXIST "%~1" (
    DEL /Q /F "%~1";
)

ECHO "%~1" has been deleted.

EXIT /B 0
