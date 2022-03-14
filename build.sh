
rm -r dist/*
mkdir -p dist/

# add option -mac, -windows, -linux, or -html if you only want one target
amulet export -r -d dist/ -a .
amulet export -r -d dist/ -a -html .

