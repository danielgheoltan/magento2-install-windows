@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

CALL php bin/magento mindmagnet-util:set-themes
CALL grunt exec:luma
CALL php bin/magento setup:static-content:deploy en_US --area="frontend" --theme="Magento/luma" --no-html-minify -f
CALL grunt less:luma & grunt watch less:luma
