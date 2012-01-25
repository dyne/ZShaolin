# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

echo "copying configurations in etc"

mkdir -p $ZHOME/sysroot/system/etc
cp z* $ZHOME/sysroot/system/etc
cp grml* $ZHOME/sysroot/system/etc
