@echo off
cls
setlocal enableDelayedExpansion

:: ----------------------------------------------------------------------------

call config

:: ---------------------------------------------------------------------------

call 00-install %1

:: call 10-install-__________-module-__________
:: call 11-install-__________-theme-__________
:: call 12-install-__________-languagepack-__________

:: call 20-install-__________-module-__________
:: call 21-install-__________-theme-__________
:: call 22-install-__________-languagepack-__________

:: ---------------------------------------------------------------------------

cd /d "!PROJECT_PATH!"

call deploy

start "Front-end" /max "!MAGENTO_BASE_URL!"
start "Back-end" /max "!MAGENTO_BASE_URL!/!MAGENTO_BACKEND_FRONTNAME!"
