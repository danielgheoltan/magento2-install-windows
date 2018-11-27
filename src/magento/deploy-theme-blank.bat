@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

CALL php bin/magento mindmagnet-util:set-themes
CALL grunt exec:blank
CALL php bin/magento setup:static-content:deploy en_US --theme="Magento/blank" --no-html-minify -f
CALL grunt less:blank & grunt watch less:blank
