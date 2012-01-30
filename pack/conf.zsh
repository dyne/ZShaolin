# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# just one module for now


check_module() {
    if ! [ -r $1.tree ]; then
	echo "error packing $1 module: tree not found"
	return 1
    fi
    return 0
}

sync_module() {
    { check_module $1 } || { return 1 }; module=$1
    
    echo "Syncing module $module from sysroot"
    rm -rf $module
    mkdir -p $module
    
    rsync -dar --files-from=$module.tree $ZHOME/sysroot/ $module/
}

strip_module() {
    { check_module $1 } || { return 1 }; module=$1

    echo "Stripping binaries in module $module"
    for i in `find $module`; do
	file $i | grep -e 'ELF.*executable' > /dev/null
	if [ $? = 0 ]; then
	    echo "strip executable $i"
	    $TOOLCHAIN/bin/$TARGET-strip $i
	fi
    done
}

alias_module() {
    { check_module $1 } || { return 1 }; module=$1

    echo "Setting aliases for module $module"
    if [ -r $ZHOME/pack/$module.aliases ]; then
	aa=`cat $module.aliases`
	cd $ZHOME/pack/$module
	for a in ${(f)aa}; do
	    dir=`dirname ${a}`
	    { test -r $dir } || continue
	    cd $ZHOME/pack/$module/$dir; a=($a)
#	    echo "($dir) ln -vf `basename ${a[1]}` ${a[2]}"
	    ln -vsf `basename ${a[1]}` ${a[2]}
	    cd $ZHOME/pack/$module
	done
	cd $ZHOME/pack
    fi
}

pack_module() {
    { check_module $1 } || { return 1 }; module=$1
    ver=${ver:-`cat $module.version`}

    echo "Packing module $module $ver"
    tar cf $module-$ver.tar $module
    lzma -z -7 $module-$ver.tar
    echo "ready to be included in assets:"
    ls -lh $module-$ver.tar.lzma
}

install_module() {
    { check_module $1 } || { return 1 }; module=$1
    ver=${ver:-`cat $module.version`}
    
    if [ $module = all ]; then
	cp $ZHOME/pack/all-$ver.tar.lzma $ZHOME/termapk/assets/system-$ver.tar.lzma.mp3
    else
	cp $ZHOME/pack/$module-$ver.tar.lzma $ZHOME/termapk/assets/$module-$ver.tar.lzma.mp3
    fi

    # special case: for system install also busybox
    { test $module = system } && { 
	cp $ZHOME/build/busybox/busybox \
	    $ZHOME/termapk/assets/busybox.mp3 }
}

module=all
{ test $2 } && { module=$2 }

{ test $module = all } && {
  cat system.tree media.tree | sort > all.tree 
  ver=`cat system.version`
}

sync_module $module
strip_module $module
alias_module $module
pack_module $module
install_module $module

# cd $ZHOME
# VER=`cat VERSION`
# tar cfz system-$VER.tar.gz system

# stat system-$VER.tar.gz
# cp system-$VER.tar.gz termapk/assets/system-$VER.tar.gz.mp3
# cp sysroot/system/bin/busybox termapk/assets/busybox.mp3
# chmod -x termapk/assets/busybox.mp3

