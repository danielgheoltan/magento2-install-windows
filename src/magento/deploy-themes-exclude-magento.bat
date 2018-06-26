@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

:: CALL php bin/magento dg-util:set-themes
CALL grunt exec
CALL php bin/magento setup:static-content:deploy en_US --area="frontend" --exclude-theme="Magento/blank" --exclude-theme="Magento/luma" --no-html-minify -f
CALL grunt less & grunt watch less
