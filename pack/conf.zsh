# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# just one module for now


check_module() {
    if ! [ -r $1.tree ]; then
	error "error packing $1 module: tree not found"
	return 1
    fi
    return 0
}

sync_module() {
    { check_module $1 } || { return 1 }; module=$1
    
    notice "Syncing module $module from sysroot"
    rm -rf $module
    mkdir -p $module
    
    rsync -dar --files-from=$module.tree $ZHOME/sysroot/ $module/
}

strip_module() {
    { check_module $1 } || { return 1 }; module=$1

    notice "Stripping binaries in module $module"
    for i in `find $module`; do
	file $i | grep -e 'ELF.*executable' > /dev/null
	if [ $? = 0 ]; then
	    act "strip executable $i"
	    $TOOLCHAIN/bin/$TARGET-strip $i
	fi
    done
}

alias_module() {
    { check_module $1 } || { return 1 }; module=$1

    notice "Setting aliases for module $module"
    if [ -r $ZHOME/pack/$module.aliases ]; then
	aa=`cat $module.aliases`
	pushd $module
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
    { check_module $1 } || { return 1 }; module=$1
    ver=${ver:-`cat $module.version`}

    notice "Packing module $module $ver"
    rm ${module}-${ver}.tar*
    tar cf ${module}-${ver}.tar $module
    lzma -z -7 ${module}-${ver}.tar
    act "ready to be included in assets:"
    ls -lh ${module}-${ver}.tar.lzma
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
    case $module in
	all|system)
		act "Including busybox binary:"
		ls -l $ZHOME/build/busybox/busybox
		cp $ZHOME/build/busybox/busybox \
	    		$ZHOME/termapk/assets/busybox.mp3 
		;;
    esac
}

module=all
{ test $2 } && { module=$2 }

{ test $module = all } && {
  rm -f all.tree && touch all.tree
  rm -f all.aliases && touch all.aliases
  for t in `find . -name '*.tree$'`; do
	cat $t | sort >> all.tree; done
  for a in `find . -name '*.aliases$'`; do
	cat $a | sort >> all.aliases; done
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

