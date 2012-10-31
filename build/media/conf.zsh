# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the compile flags
OPTIMIZATIONS="-O3"
ARCH="-mfloat-abi=softfp -march=armv7-a -mtune=cortex-a8"

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


###########################################
## COMPILE PACKAGES:


prepare_sources


########
## IMAGE


## imagemagick
{ test ! -r ImageMagick.done } && {
    cp ImageMagick.Makefile.am ImageMagick/Makefile.am
    pushd ImageMagick
    autoreconf -i
    popd
    compile ImageMagick default "--disable-shared --disable-deprecated --without-fontconfig --without-x"
}
{ test -r ImageMagick.done } && { zinstall ImageMagick }




########
## AUDIO

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

########
## VIDEO

compile x264 default "--enable-static --cross-prefix=${TARGET}-"
zinstall x264

compile ffmpeg "--prefix=$PREFIX --disable-shared --enable-static --enable-gpl --enable-version3 --extra-libs=-static --extra-cflags=-static-libgcc" "--enable-zlib --enable-cross-compile --cross-prefix=${TARGET}- --target-os=linux --cc=$TARGET-gcc --host-cc=$TARGET-gcc --arch=armv5 --disable-asm --disable-debug --enable-libvorbis --enable-libx264 --enable-libspeex"
pushd ffmpeg
make doc/ffmpeg.1
make doc/ffprobe.1
popd
zinstall ffmpeg


# TODO: theora broken

# if ! [ -r $pkg[theora].done ]; then
#     cd $pkg[theora]; CFLAGS=$CFLAGS ./configure --host=$TARGET --prefix=$PREFIX \
# 	--disable-shared --enable-static --with-pic=no \
# 	--disable-spec --disable-examples --disable-sdltest
#     make
# fi
# if ! [ -r $pkg[theora].done ]; then
#     cp $pkg[theora].configure.ac $pkg[theora]/configure.ac
#     cd $pkg[theora]; aclocal -I m4 && autoconf && automake && cd .. && \
# 	compile $pkg[theora] default "--disable-shared --enable-static --with-pic=no --disable-examples"
# fi
