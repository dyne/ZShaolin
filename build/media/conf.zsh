# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the compile flags
#OPTIMIZATIONS="-O3"
#ARCH="-mfloat-abi=softfp -march=armv7-a -mtune=cortex-a8"

###########################################
## COMPILE PACKAGES:


prepare_sources




########
## IMAGE


## imagemagick
# { test ! -r ImageMagick.done } && {
#     cp Makefile.am.ImageMagick ImageMagick/Makefile.am
#     pushd ImageMagick
#     autoreconf -i >> $LOGS
#     popd
# }

compile jasper default
zinstall jasper

compile lcms2 default
zinstall lcms2

compile libexif default
zinstall libexif

compile libpng	default
zinstall libpng

compile jpeg	default
zinstall jpeg

compile giflib	default
zinstall giflib

compile tiff	default
zinstall tiff

compile	freetype	default
zinstall freetype

####################
## META DATA IMAGE EDITOR
pushd jhead
zmake
cp jhead $PREFIX/bin/
popd

# DCRAW
{ test -r dcraw.o } || { $CC ${=CFLAGS} -I $ZHOME/system/include -c dcraw.c }
{ test -r dcraw } || { $LD ${=LDFLAGS} -L $ZHOME/system/lib dcraw.o -o dcraw -lm -llcms2 -ljasper -ljpeg -lpthread -lm }
cp dcraw $PREFIX/bin/


####################
## ImageMagick suite
compile ImageMagick default \
    --disable-shared --disable-deprecated --without-fontconfig --without-x \
    --without-pango --without-openexr

zinstall ImageMagick


########
## AUDIO

## libmad
compile lame	default
zinstall lame

## libogg
compile libogg default "--disable-shared --enable-static --with-pic=no"
zinstall libogg

## libvorbis
compile libvorbis default "--disable-shared --enable-static --with-pic=no"
zinstall libvorbis

## flac
# { test ! -r flac.done } && {
#     echo "Applying makefile fix to flac"
#     cp flac.Makefile.am flac/Makefile.am
#     cp flac.configure.in flac/configure.in
#     pushd flac
#     autoreconf -i
#     popd
#     compile flac default \
# 	"--disable-shared --enable-static --with-pic=no --disable-asm-optimizations"
# }
# { test -r flac.done } && { zinstall flac }
    

## speex
compile speex default "--disable-shared --enable-static --with-pic=no"
zinstall speex

# oggz
compile liboggz default "--disable-shared --enable-static --with-pic=no"
zinstall liboggz

## sox
compile sox default "--disable-shared --with-distro=ZShaolin"
zinstall sox

#pushd id3ren/src
#zmake
#popd


########
## VIDEO

compile x264 default "--disable-shared --enable-static --cross-prefix=${ZTARGET}-"
zinstall x264

compile ffmpeg "--prefix=$PREFIX --disable-shared --enable-static --enable-gpl --enable-version3 --extra-libs=-static --extra-cflags=-static-libgcc" "--enable-zlib --enable-cross-compile --cross-prefix=${ZTARGET}- --target-os=linux --cc=${ZTARGET}-gcc --host-cc=${ZTARGET}-gcc --arch=armv5 --disable-asm --disable-debug --enable-libvorbis --enable-libx264 --enable-libspeex"
pushd ffmpeg
make doc/ffmpeg.1
make doc/ffprobe.1
popd
zinstall ffmpeg


return

notice "Building xvidcore"
{ test -r xvidcore.done } || {
	pushd xvidcore/build/generic
	zconfigure default "--disable-shared --enable-static"
	zmake
	{ test $? = 0 } && { touch ../../../xvidcore.done }
	popd
}
{ test -r xvidcore.installed } || {
	pushd xvidcore/build/generic
	zinstall
	{ test $? = 0 } && { touch ../../../xvidcore.installed }
	popd
}
act "done."

# TODO: theora broken

# if ! [ -r $pkg[theora].done ]; then
#     cd $pkg[theora]; CFLAGS=$CFLAGS ./configure --host=${ZTARGET} --prefix=$PREFIX \
# 	--disable-shared --enable-static --with-pic=no \
# 	--disable-spec --disable-examples --disable-sdltest
#     make
# fi
# if ! [ -r $pkg[theora].done ]; then
#     cp $pkg[theora].configure.ac $pkg[theora]/configure.ac
#     cd $pkg[theora]; aclocal -I m4 && autoconf && automake && cd .. && \
# 	compile $pkg[theora] default "--disable-shared --enable-static --with-pic=no --disable-examples"
# fi
