# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# just one module for now


sync_module() {
    notice "Syncing from sysroot"
    rm -rf system
    mkdir -p system
    
    rsync -dar --files-from=all.tree $ZHOME/sysroot/ system/
}

strip_module() {
    notice "Stripping binaries"
    for i in `find system -type f`; do
	file $i | grep -e 'ELF.*executable' > /dev/null
	if [ $? = 0 ]; then
	    act "strip executable $i"
	    $TOOLCHAIN/bin/$TARGET-strip $i
	fi
    done
}

alias_module() {
    notice "Setting aliases"
    if [ -r $ZHOME/pack/all.aliases ]; then
	aa=`cat all.aliases`
	pushd system
	for a in ${(f)aa}; do
	    dir=`dirname ${a}`
	    { test -r $dir } || continue
	    pushd $dir; a=($a)
#	    echo "($dir) ln -vf `basename ${a[1]}` ${a[2]}"
	    ln -vsf `basename ${a[1]}` ${a[2]}
	    popd
	done
	popd
    fi
}

pack_module() {
    ver=${ver:-`cat system.version`}
    notice "Packing system version $ver"
    tar cf system-${ver}.tar system
    { test -r system-${ver}.tar.lzma } && { rm -f system-${ver}.tar.lzma }
    lzma -z -7 system-${ver}.tar
    act "ready to be included in assets:"
    ls -lh system-${ver}.tar.lzma
}

install_module() {
    ver=${ver:-`cat system.version`}
    cp $ZHOME/pack/system-$ver.tar.lzma $ZHOME/termapk/assets/system-$ver.tar.lzma.mp3
    act "Including busybox binary:"
    ls -l $ZHOME/build/busybox/busybox
    cp $ZHOME/build/busybox/busybox \
	$ZHOME/termapk/assets/busybox.mp3 
}

rm -f all.tree && touch all.tree
rm -f all.aliases && touch all.aliases
for t in `find . -name '*.tree'`; do
	cat $t | sort >> all.tree; done
for a in `find . -name '*.aliases'`; do
	cat $a | sort >> all.aliases; done
ver=`cat system.version`

sync_module
strip_module
alias_module
pack_module
install_module

# cd $ZHOME
# VER=`cat VERSION`
# tar cfz system-$VER.tar.gz system

# stat system-$VER.tar.gz
# cp system-$VER.tar.gz termapk/assets/system-$VER.tar.gz.mp3
# cp sysroot/system/bin/busybox termapk/assets/busybox.mp3
# chmod -x termapk/assets/busybox.mp3

