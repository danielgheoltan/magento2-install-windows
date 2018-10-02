@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

CALL php bin/magento mindmagnet-util:set-themes
CALL grunt exec:%1
CALL php bin/magento setup:static-content:deploy en_US --area="frontend" --theme="%2" --no-html-minify -f
CALL grunt less:%1 & grunt watch less:%1
