

rm -rf pack/*
rsync -dar --files-from=system.tree --delete . pack/

for i in `find pack`; do
    file $i | grep 'executable, ARM' > /dev/null
    if [ $? = 0 ]; then
	$TOOLCHAIN/bin/$TARGET-strip $i
    fi
done

cd pack/bin
# symlink shells
ln -s zsh sh
ln -s zsh ash
ln -s zsh bash
cd ..


VER=`cat $ZHOME/VERSION`
tar cfz $ZHOME/system-$VER.tar.gz .

cd $ZHOME
stat system-$VER.tar.gz
cp system-$VER.tar.gz termapk/assets/system-$VER.tar.gz.mp3
cp sysroot/pack/bin/busybox termapk/assets/busybox.mp3
chmod -x termapk/assets/busybox.mp3

