

rm -rf pack/*
rsync -dar --files-from=system.tree --delete . pack/

for i in `find pack`; do
    file $i | grep 'executable, ARM' > /dev/null
    if [ $? = 0 ]; then
	$TOOLCHAIN/bin/$TARGET-strip $i
    fi
done

cd pack

tar cfz $ZHOME/ZShaolin.tar.gz .

cd $ZHOME
stat ZShaolin.tar.gz

