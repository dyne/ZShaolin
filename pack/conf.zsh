# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# just one module for now


ver=`cat ${ZHOME}/VERSION`

# android toolchain strip
export TOOLCHAIN=$ZHOME/toolchains/arm-linux-androideabi-4.6
export TARGET=arm-linux-androideabi
export STRIP=${TOOLCHAIN}/bin/${TARGET}-strip


streamline_zshaolin() {
    act "including core scripts in dojo"

    mkdir -p floor/var/pid
    mkdir -p floor/var/log

    # now etc and the helper scripts (new since 0.9.1)
    rsync -ar $ZHOME/conf/aux		floor/
    rsync -ar $ZHOME/conf/etc		floor/
    rsync -ar $ZHOME/conf/helpers	floor/
    # eventually zcompile some helpers, still too small to need that
    zcompile floor/etc/grmlrc

    rm -f zshaolin.etc
}



streamline() {
    module=$1
    act "streamlining $module"

    # reset from previous streamlining    
    mkdir -p tmp && rm -rf tmp/* > /dev/null 2>/dev/null

    # find file trees in the selected dojo
    trees=(`find $module -name '*.tree'`)
    for t in ${=trees}; do
	# only first arg (2nd for rename, would break rsync)
	act "reading $t"
	cat $t | awk '{print $1}' | sort >> tmp/all.tree; done

    # find aliases to be set for the selected dojo	
    shadows=(`find $module -name '*.aliases'`);
    for a in ${=shadows}; do
	act "reading $a"
	cat $a | sort >> tmp/all.aliases; done

    # do the actual copy into the new system
    rsync -dar --files-from=tmp/all.tree $ZHOME/system/ floor/

    # rename those that need it (2nd arg in .tree)
    for i in `cat tmp/all.tree | awk '{if($2) print $1 ";" $2}'`; do
	src=${i[(ws:;:)1]}
	dst=${i[(ws:;:)2]}
	act "rename $src in $dst"
	mv floor/${src} floor/${dst}
    done

    if [ -r tmp/all.aliases ]; then
	act "placing aliases in $module"
	aa=`cat tmp/all.aliases`
	pushd floor
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

clean_floor() {
    # deletes contents from last packaging, preparing for the new one
    act "cleaning up the floor"
    { test -r floor } && { rm -rf floor }
    mkdir floor && cp $ZHOME/VERSION floor/
}

strip_floor() {
    notice "Stripping binaries on the floor"
    for i in `find floor -type f`; do
	file $i | grep -e 'ELF.*executable' > /dev/null
	if [ $? = 0 ]; then
	    act "strip executable $i"
	    ${STRIP} $i
	fi
    done
}

pack_dojo() {
    notice "Compressing dojo..."
    rm -rf system # clear old dojo
    mv floor system # renames the floor to dojo
    
    tar cf system.tar system
    { test -r system.tar.lzma } && { rm -f system.tar.lzma }
    lzma -z -7 --verbose system.tar
    
    notice "Including dojo in assets"
    ls -lh system.tar.lzma
    cp -v system.tar.lzma $ZHOME/termapk/assets/system.tar.lzma.mp3

    act "including busybox in assets"
    ls -l $ZHOME/build/busybox/busybox.bin && \
	cp -v $ZHOME/build/busybox/busybox.bin \
	$ZHOME/termapk/assets/busybox.mp3 
    
}    

pack_weapon() {
    w=${1:-all}
    notice "Packing weapon: $module"
    rm -rf $w
    mv floor $w
    
    tar cf $w.tar $w
    { test -r $w.tar.lzma } && { rm -f $w.tar.lzma }
    lzma -z -7 --verbose $w.tar
    mv $w.tar.lzma weapons/
    
}



# MAIN()

notice "Packaging ZShaolin version $ver"

# module is set by zmake from commandline args, defaults to "list"
typeset -U weap # remove duplicates from array    
dojo=(); weap=();
{ test "$module" = "list" } && {
    for i in `ls dojos/`; do dojo+=($i); done
    for w in `ls weapons/`; do weap+=(${w[(ws:.:)1]}); done
    notice "Choose dojo: ${dojo}"
    notice "Available weapons: ${weap}"
    return 0
}

act "module: $module"

{ test -r dojos/$module } && {
    notice "Streamlining dojo: $module"
    
    clean_floor # clean first and every time a new pack is done
    
# create the dojo
    streamline dojos/$module # binaries
    streamline_zshaolin # confs and scripts
    strip_floor # strips all in floor
    pack_dojo # pack and copy into assets
    return 0
}

{ test -r weapons/$module } && {
    notice "Packing weapon: $module"
    clean_floor
    streamline weapons/$module
    strip_floor
    pack_weapon $module
    return 0
}

error "No pack action for module $module"

# cd $ZHOME
# VER=`cat VERSION`
# tar cfz system-$VER.tar.gz system

# stat system-$VER.tar.gz
# cp system-$VER.tar.gz termapk/assets/system-$VER.tar.gz.mp3
# cp sysroot/system/bin/busybox termapk/assets/busybox.mp3
# chmod -x termapk/assets/busybox.mp3

