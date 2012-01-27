# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

rm -rf $ZHOME/system
mkdir -p $ZHOME/system

rsync -dar --files-from=system.tree --delete sysroot/ system/

for i in `find $ZHOME/system`; do
    file $i | grep 'executable, ARM' > /dev/null
    if [ $? = 0 ]; then
	$TOOLCHAIN/bin/$TARGET-strip $i
    fi
done

cd $ZHOME/system/bin
# symlink shells
ln -s zsh sh
ln -s zsh ash
ln -s zsh bash
cd ../..

cd $ZHOME
VER=`cat VERSION`
tar cfz system-$VER.tar.gz system

stat system-$VER.tar.gz
cp system-$VER.tar.gz termapk/assets/system-$VER.tar.gz.mp3
cp sysroot/system/bin/busybox termapk/assets/busybox.mp3
chmod -x termapk/assets/busybox.mp3

