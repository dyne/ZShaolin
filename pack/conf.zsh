# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# just one module for now


sync_module() {
    notice "Syncing from system"
    rm -rf system
    mkdir -p system

    rm -f all.tree && touch all.tree
    rm -f all.aliases && touch all.aliases
    for t in `find . -name '*.tree'`; do
	# only first arg (2nd for rename, would break rsync)
	cat $t | awk '{print $1}' | sort >> all.tree; done
    for a in `find . -name '*.aliases'`; do
	cat $a | sort >> all.aliases; done
    
    rsync -dar --files-from=all.tree $ZHOME/system/ system/

    # rename those that need it (2nd arg in .tree)
    for t in `find . -name '*.tree'`; do
      for i in `cat ${t} | awk '{if($2) print $1 ";" $2}'`; do
	src=${i[(ws:;:)1]}
	dst=${i[(ws:;:)2]}
	act "rename $src in $dst"
	mv system/${src} system/${dst}
      done
    done

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

zcompile_module() {
    notice "Zcompiling zsh scripts"
    zcompile system/etc/grmlrc
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
    ver=${ver:-`cat ${ZHOME}/VERSION`}
    notice "Packing system version: $ver"
    tar cf system-${ver}.tar system
    { test -r system-${ver}.tar.lzma } && { rm -f system-${ver}.tar.lzma }
    lzma -z -7 system-${ver}.tar
    act "ready to be included in assets:"
    ls -lh system-${ver}.tar.lzma
}

install_module() {
    ver=${ver:-`cat ${ZHOME}/VERSION`}
    cp $ZHOME/pack/system-$ver.tar.lzma $ZHOME/termapk/assets/system-$ver.tar.lzma.mp3
    act "Including busybox binary:"
    ls -l $ZHOME/build/busybox/busybox.bin && \
    cp $ZHOME/build/busybox/busybox.bin \
	$ZHOME/termapk/assets/busybox.mp3 
}


ver=`cat ${ZHOME}/VERSION`

notice "Packing system version $ver"

sync_module
strip_module
zcompile_module
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

