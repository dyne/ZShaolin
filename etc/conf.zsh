# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

echo "copying configurations in etc"

mkdir -p $ZHOME/sysroot/system/etc
cp zlogin grmlrc $ZHOME/sysroot/system/etc
cp grml.conf $ZHOME/sysroot/.grml.conf
cp zshrc $ZHOME/sysroot/.zshrc
