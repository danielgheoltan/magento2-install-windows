@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

:: Enable maintenance mode
CALL php bin/magento maintenance:enable

:: Cleanup
CALL :deleteFolder "generated"
CALL :deleteFolder "var/di"

:: Flush cache
CALL php bin/magento cache:flush

:: Compile code
CALL php bin/magento setup:di:compile

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
