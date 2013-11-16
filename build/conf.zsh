# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details


{ test -r $module } || { 
  error "Module not found: $module"
  return 1 }


typeset ZTARGET TOOLCHAIN PREFIX
typeset CC CXX LD AR RANLIB OBJCOPY STRIP



init-toolchain-crosstool() {

notice "Initializing Crosstool-NG toolchain"

# configure the target
export ZTARGET=arm-dyne-linux-gnueabi

# toolchain full path
export TOOLCHAIN=$ZHOME/toolchains/crosstool-ng/x-tools

# configure the install prefix
export PREFIX=$ZHOME/system

# configure the compilers
export CC=${ZHOME}/wrap/static-cc
export CXX=${ZHOME}/wrap/static-c++
export LD=${ZHOME}/wrap/static-ld
export AR=${TOOLCHAIN}/bin/${ZTARGET}-ar
export RANLIB=${TOOLCHAIN}/bin/${ZTARGET}-ranlib
export OBJCOPY=${TOOLCHAIN}/bin/${ZTARGET}-objcopy
export STRIP=${TOOLCHAIN}/bin/${ZTARGET}-strip


# configure the compile flags
OPTIMIZATIONS="-Os -O2"
CFLAGS=(-static -static-libgcc $OPTIMIZATIONS $ARCH)
#CFLAGS="$OPTIMIZATIONS $ARCH -I$TOOLCHAIN/$ZTARGET/sysroot/usr/include -I$PREFIX/include $ANDROID_CFLAGS"
CPPFLAGS=(-I$PREFIX/include -I$TOOLCHAIN/$ZTARGET/sysroot/usr/include -I$PREFIX/include)
CXXFLAGS=$CFLAGS
LDFLAGS=(-static -static-libgcc -L$TOOLCHAIN/$ZTARGET/sysroot/lib -L$TOOLCHAIN/$ZTARGET/sysroot/usr/lib -L$PREFIX/lib -L$PREFIX/usr/lib)
# LDFLAGS="-L$TOOLCHAIN/$ZTARGET/sysroot/lib -L$TOOLCHAIN/$ZTARGET/sysroot/usr/lib -L$PREFIX/lib -L$PREFIX/usr/lib"
# LDFLAGS="$ANDROID_LDFLAGS -L$PREFIX/lib -L$PREFIX/usr/lib"
# PATH="$PATH:$ANDROID_NDK/toolchains/$ANDROID_TOOLCHAIN/bin"
PATH=$TOOLCHAIN/bin:$ZHOME/wrap:/bin:/usr/bin

export PATH
export CFLAGS
export CPPFLAGS
export CXXFLAGS
export LDFLAGS
}


init-toolchain-android() {

notice "Initializing Android-NDK toolchain"

# configure the target
export ZTARGET=arm-linux-androideabi

# toolchain full path
export TOOLCHAIN=$ZHOME/toolchains/arm-linux-androideabi-4.6

# NDK full path
NDK=/android/android-ndk-r9b

# SYSROOT=$NDK/platforms/android-8/arch-arm
export SYSROOT=$TOOLCHAIN/sysroot

# configure the install prefix
export PREFIX=$ZHOME/system

# configure the compilers
export CC=${ZHOME}/wrap/static-cc
export CXX=${ZHOME}/wrap/static-c++
export LD=${ZHOME}/wrap/static-ld
#CC=${TOOLCHAIN}/bin/${ZTARGET}-gcc
#CXX=${TOOLCHAIN}/bin/${ZTARGET}-g++
#LD=${TOOLCHAIN}/bin/${ZTARGET}-ld

export AR=${TOOLCHAIN}/bin/${ZTARGET}-ar
export RANLIB=${TOOLCHAIN}/bin/${ZTARGET}-ranlib
export OBJCOPY=${TOOLCHAIN}/bin/${ZTARGET}-objcopy
export STRIP=${TOOLCHAIN}/bin/${ZTARGET}-strip

# configure the compile flags
CFLAGS=(--sysroot=$SYSROOT)
CFLAGS+=(-march=armv7-a -mfloat-abi=softfp) # -mfpu=neon) # architecture
CFLAGS+=(-Os -O2) # optimization
CPPFLAGS=(-I$TOOLCHAIN/$ZTARGET/sysroot/usr/include -I$PREFIX/include)
# some notes
#ANDROID_CFLAGS="-DANDROID -D__ANDROID__ -DSK_RELEASE -nostdlib -fpic -fno-short-enums -fgcse-after-reload -frename-registers"
#ANDROID_LDFLAGS="-L${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/usr/lib -Xlinker -z -Xlinker muldefs -nostdlib -Bdynamic -Xlinker -dynamic-linker -Xlinker /system/bin/linker -Xlinker -z -Xlinker nocopyreloc -Xlinker --no-undefined $ANDROID_NDK/platforms/$ANDROID_PLATFORM/usr/lib/crtbegin_dynamic.o $ANDROID_NDK/platforms/$ANDROID_PLATFORM/usr/lib/crtend_android.o -ldl -lm -lc -lgcc"


# CPPFLAGS+=(--sysroot=$SYSROOT)

CXXFLAGS=$CFLAGS
LDFLAGS=(-L$SYSROOT/usr/lib -L$PREFIX/lib -L$PREFIX/usr/lib)
LDFLAGS+=($ZHOME/wrap/libzshaolin.a)
#LDFLAGS+=(-ldl -lm -lc -lgcc)
LDFLAGS+=(--sysroot=$SYSROOT)
LDFLAGS+=(-Wl,--fix-cortex-a8)
# LDFLAGS="-L$TOOLCHAIN/$ZTARGET/sysroot/lib -L$TOOLCHAIN/$ZTARGET/sysroot/usr/lib -L$PREFIX/lib -L$PREFIX/usr/lib"
# LDFLAGS="$ANDROID_LDFLAGS -L$PREFIX/lib -L$PREFIX/usr/lib"
# PATH="$PATH:$ANDROID_NDK/toolchains/$ANDROID_TOOLCHAIN/bin"
PATH=$TOOLCHAIN/bin:$ZHOME/wrap:/bin:/usr/bin

# make sure we have the wrapper library for ndk crap
#{ test -r $ZHOME/wrap/libzshaolin.a } || {
	pushd $ZHOME/wrap
	$TOOLCHAIN/bin/${ZTARGET}-gcc -c zshaolin.c -o zshaolin.o
	$TOOLCHAIN/bin/${ZTARGET}-ar rcs libzshaolin.a zshaolin.o
	popd
#}

export PATH
export CFLAGS
export CPPFLAGS
export CXXFLAGS
export LDFLAGS
}


init-toolchain() {

case "$1" in
	android) init-toolchain-android ;;
	crosstool) init-toolchain-crosstool ;;
	"") act "Unconfigured toolchain, default to crosstool"
		init-toolchain-crosstool ;;
	*) error "Unknown toolchain: $1"; return 1 ;;
esac
# make sure the toolchain exists in /usr
if ! [ -r $TOOLCHAIN/bin/${ZTARGET}-gcc ]; then
    error "error: toolchain not found: $TOOLCHAIN/bin/$ZTARGET-gcc"
    error "first you need to bootstrap."
#    return 1
fi

notice "ZShaolin build system"
act "Target:    $ZTARGET"
act "Toolchain: $TOOLCHAIN"
act "Install:   $PREFIX"
func "CFLAGS:    $CFLAGS"
func "LDFLAGS:   $LDFLAGS"
func "Command:   ${=@}"


## make sure basic directories exist
mkdir -p $PREFIX/sbin
mkdir -p $PREFIX/bin

return 0
}


# TODO: clean_sources
prepare_sources() {
    # look for a file names "Sources", download and decompress entries
    # format of file: name version compression (complete filename when merged)
    { test -r Sources } || {
	error "Sources not found, nothing to build here"
	return 1
    }
    for src in `cat Sources | awk '
/^#/ {next}
/^./ { print $1 ";" $2 ";" $3 }'`; do
	name="${src[(ws:;:)1]}"
	ver="${src[(ws:;:)2]}"
	arch="${src[(ws:;:)3]}"
	file="${name}${ver}${arch}"
	func "preparing source for ${name}${ver}"
	# download the file
	{ test -r ${file} } || {
	    act "downloading ${file}"
	    wget ${REPO}/${file}
	}
	# decompress the file
	{ test -r ${name} } || {
	    act "decompressing ${name}"
	    case $arch in
		## OPK
		.opk)
		    mkdir -p extract
		    pushd extract
		    ln -sf ../${file} .
		    ar x ${file}
		    if [ -r data.tar.gz ]; then
			tar xfz data.tar.gz
			if [ $? = 0 ]; then
			    touch ../${name}.done
			    touch ../${name}.installed
			else error "error decompressing tarred package"; fi
		    else error "data not found in package"; fi
		    popd
		    ;;

		## IPK
		*.ipk)
		    mkdir -p extract
		    pushd extract
		    ln -sf ../${file} ${name}${ver}.tar.gz
		    tar xfz ${name}${ver}.tar.gz
		    if [ -r data.tar.gz ]; then
			tar xfz data.tar.gz
			if [ $? = 0 ]; then
			    touch ../${name}.done
			    touch ../${name}.installed
			else error "error decompressing tarred package"; fi
		    else error "data not found in package"; fi
		    popd
		    ;;

		## BARE SOURCE
		*.tar.gz)  tar xfz ${file}; mv ${name}${ver} ${name} ;;
		*.tar.bz2) tar xfj ${file}; mv ${name}${ver} ${name} ;;
		*.tar.xz) tar xfJ ${file}; mv ${name}${ver} ${name} ;;

		*) error "compression not supported: $arch"
	    esac
	    
	}
	act "${name} source ready"
    done
    LOGS="`pwd`/build.log"
    { test -r $LOGS } && { rm -f $LOGS && touch $LOGS }
}

# array of args shifted around by compile()
typeset -a compile_args


zconfigure() {
    func "zconfigure() : $@"
    args=(${=@})

    # configure the compile flags defaults
#    CFLAGS=${CFLAGS:-"-static -static-libgcc $OPTIMIZATIONS $ARCH -I$TOOLCHAIN/$ZTARGET/sysroot/usr/include -I$PREFIX/include"}
#    CXXFLAGS=${CXXFLAGS:-$CFLAGS}

    { test -r configure } || {
	error "configure not found in `pwd`"
	return 1 }

    confflags=($=@)

    { test "$args[1]" = "default" } && {
	# expunge an array element
	confflags=${confflags:#default}
	confflags=(--host=arm-linux-gnueabi --prefix=$PREFIX $confflags)
    }

    func "CFLAGS = $CFLAGS"
    func "configure = $confflags"

     PATH=${PATH} \
	 CC="${CC}" CXX="${CXX}" LD="${LD}" STRIP="${STRIP}" \
	 AR="${AR}" RANLIB="${RANLIB}" OBJCOPY="${OBJCOPY}" \
	 CFLAGS="$CFLAGS $extracflags" \
	 CPPFLAGS="$CPPFLAGS" \
	 CXXFLAGS="$CXXFLAGS" \
	 LDFLAGS="$LDFLAGS" \
	 CONFIG_SITE="$ZHOME/build/config.site" \
	 PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
	 ./configure ${=confflags}
     { test $? = 0 } || { error "error: configure returns error value"; return 1 }
     act "configure was succesful"
     return 0
}

zmake() {

    # pass extra arguments to make (for instance targets)
    # check if logs don't exist print out to streen
    if [ -r $LOGS ]; then
	PATH=${PATH} \
	    CC="${CC}" CXX="${CXX}" LD="${LD}" STRIP="${STRIP}" \
	    AR="${ZTARGET}-ar" RANLIB="${ZTARGET}-ranlib" \
	    CFLAGS="$CFLAGS $extracflags" \
	    CPPFLAGS="$CPPFLAGS" \
	    CXXFLAGS="$CXXFLAGS" \
	    LDFLAGS="$LDFLAGS" \
	    make V=1 ${=@}
    else
	PATH=${PATH} \
	    CC="${CC}" CXX="${CXX}" LD="${LD}" STRIP="${STRIP}" \
	    AR="${ZTARGET}-ar" RANLIB="${ZTARGET}-ranlib" \
	    CFLAGS="$CFLAGS $extracflags" \
	    CPPFLAGS="$CPPFLAGS" \
	    CXXFLAGS="$CXXFLAGS" \
	    LDFLAGS="$LDFLAGS" \
	    make V=1 ${=@}
    fi
    { test $? = 0 } || {
	error "error: make returns error value $?"
	return 1
    }
    act "make was successful"
    return 0
}

compile() {
    notice "Building $1" | tee -a ${LOGS}
    func "compile() : $@"
    { test -r $1.done } && {
	act "$1 already built, skipping compilation"
	return 1 }


    { test -r $1 } || {
    	error "source directory $1 not found, skipping compilation"
    	return 1 }

    pushd $1

    # eliminate path element from args
    compile_args=(${=@}) && shift compile_args
    # fancy search in array by zsh

    { test "${compile_args[(r)nomake]}" -ge 1 } && {
    # returns 1 if element with value nomake is found
	compile_args=${compile_args:#nomake}
       # eliminates element with value nomake from array
	nomake=1
    }


    { test -r configure } && {
	func "launching configure ${compile_args}"
	zconfigure ${compile_args}

	{ test $? = 0 } || {
	    error "error: $1 cannot configure, build left incomplete"
	    popd; return 1 }
    }

    { test "$nomake" = "1" } || {

	{ test -r Makefile } && {
	    zmake # no arguments, use zmake directly from script if a
	# customization is needed

	    { test $? = 0 } || {
		error "error: make on $1 failed, build left incomplete"
		popd; return 1 }
	}

    }
    act "Build completed successfully for $1"
    popd
    touch $1.done
    return 0
}

zinstall() {
    func "zinstall() : $@"
    { test ! -r $1.done } && {
	error "$1 not yet built, skipping installation"
	return 1 }

    { test -r $1.installed } && { test "$FORCE" = "0" } && {
	act "$1 is already installed, skipping"
	return 1 }

    target=install
    { test "$2" = "" } || { target="$2" }

    act "installing $1 (target ${target})" | tee -a ${LOGS}

    PATH="${PATH}" PREFIX="$PREFIX" \
	make -C $1 ${target}
    { test $? = 0 } || {
	error "error: $1 cannot make install, check permissions"
	return 1
    }

    notice "$1 installed"
    touch ${1}.installed
    return 0
}

zndk-build() {
    PATH="$NDK:$PATH"

    pushd $1
    ndk-build
    popd

    # { test ! -r $1.done } && {
    # 	error "$1 not yet built, skipping installation"
    # 	return 1 }

    # { test -r $1.installed } && { test "$FORCE" = "0" } && {
    # 	act "$1 is already installed, skipping"
    # 	return 1 }
}


case $operation in
    clean)
	    notice "Cleaning module: $module"
	    pushd $module
	    for s in `cat Sources | awk '!/^#/ { print $1 }'`; do
		act "clean $s"
		rm -rf ${s} ${s}.done ${s}.installed
		{ test -r extract } && { rm -rf extract }
	    done
	    popd
	notice "All clean now."
	;;
    *)
    	notice "Building module: $module"
    	pushd $ZHOME/build
	init-toolchain `cat $module/Toolchain`
	enter $module ${=@}
	popd
	notice "Copying scripts and configurations present in module $module"
	    { test -r ${module}/bin }   && { rsync -dar ${module}/bin   $PREFIX/ }
	    { test -r ${module}/etc }   && { rsync -dar ${module}/etc   $PREFIX/ }
	    { test -r ${module}/var }   && { rsync -dar ${module}/var   $PREFIX/ }
	    { test -r ${module}/share } && { rsync -dar ${module}/share $PREFIX/ }

    	notice "Build completed, summary:"
	    notice "$module module"
	    summary=`find $ZHOME/build/$module -name "*.done"`
	    summary+="\n"
	    summary+=`find $ZHOME/build/$module -name "*.installed"`
	    echo ${summary} | sort
	;;
esac
