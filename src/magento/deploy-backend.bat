@ECHO OFF
CLS

:: ----------------------------------------------------------------------------

CALL grunt exec:backend
CALL php bin/magento setup:static-content:deploy en_US --area="adminhtml" --no-html-minify -f
CALL grunt less:backend & grunt watch less:backend
