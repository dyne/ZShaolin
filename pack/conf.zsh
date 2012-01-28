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
    ver=`cat $module.version`

    echo "Packing module $module $ver"
    tar cfz $module-$ver.tar.gz $module
    echo "ready to be included in assets:"
    ls -lh $module-$ver.tar.gz
}

install_module() {
    { check_module $1 } || { return 1 }; module=$1
    ver=`cat $module.version`

    cp $ZHOME/pack/$module-$ver.tar.gz $ZHOME/termapk/assets/$module-$ver.tar.gz.mp3
    # special case: for system install also busybox
    { test $module = system } && { 
	cp $ZHOME/build/busybox/busybox \
	    $ZHOME/termapk/assets/busybox.mp3 }
}

sync_module system
strip_module system
alias_module system
pack_module system
install_module system

# cd $ZHOME
# VER=`cat VERSION`
# tar cfz system-$VER.tar.gz system

# stat system-$VER.tar.gz
# cp system-$VER.tar.gz termapk/assets/system-$VER.tar.gz.mp3
# cp sysroot/system/bin/busybox termapk/assets/busybox.mp3
# chmod -x termapk/assets/busybox.mp3

