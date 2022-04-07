
rmdir /s dist
mkdir dist

REM add option -mac, -windows, -linux, or -html if you only want one target
amulet export -r -d dist/ -a .
amulet export -r -d dist/ -a -html .

