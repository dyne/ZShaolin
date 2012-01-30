# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


# packages
typeset -A pkg
pkg=(
    # image
    imagemagick ImageMagick-6.7.4-10
    # audio
    libogg  libogg-1.3.0
    libvorbis libvorbis-1.3.2
    flac flac-1.2.1
    speex speex-1.2rc1
    oggz liboggz-1.1.1 
    sox sox-14.3.2
    #video
    theora libtheora-1.1.1
    x264 x264-snapshot-20120126-2245
    ffmpeg ffmpeg-0.10

)

if [ "$1" = "clean" ]; then
    for p in $pkg; do
	clean $p
    done
    return 0
fi


###########################################
## COMPILE PACKAGES:




########
## IMAGE


## imagemagick
{ test ! -r $pkg[imagemagick].done } && {
    cp $pkg[imagemagick].Makefile.am $pkg[imagemagick]/Makefile.am
    cd $pkg[imagemagick]; autoreconf -i; cd -
    compile $pkg[imagemagick] default "--disable-shared --disable-deprecated"
}
{ test -r $pkg[imagemagick].done } && { zinstall $pkg[imagemagick] }




########
## AUDIO

## libogg
compile $pkg[libogg] default "--disable-shared --enable-static --with-pic=no"
zinstall $pkg[libogg]

## libvorbis
compile $pkg[libvorbis] default "--disable-shared --enable-static --with-pic=no"
zinstall $pkg[libvorbis]

## flac
{ test ! -r $pkg[flac].done } && {
    echo "Applying makefile fix to flac"
    cp $pkg[flac].Makefile.am $pkg[flac]/Makefile.am
    cp $pkg[flac].configure.in $pkg[flac]/configure.in
    cd $pkg[flac] && autoreconf -i && cd -
    compile $pkg[flac] default \
	"--disable-shared --enable-static --with-pic=no --disable-asm-optimizations"
}
{ test -r $pkg[flac].done } && { zinstall $pkg[flac] }
    

## speex
compile $pkg[speex] default "--disable-shared --enable-static --with-pic=no"
zinstall $pkg[speex]

# oggz
compile $pkg[oggz] default "--disable-shared --enable-static --with-pic=no"
zinstall $pkg[oggz]

## sox
compile $pkg[sox] default "--disable-shared --with-distro=ZShaolin"
zinstall $pkg[sox]

########
## VIDEO


compile $pkg[x264] default "--disable-shared --enable-static --cross-prefix=$TARGET-"
zinstall $pkg[x264]

compile $pkg[ffmpeg] "--prefix=$PREFIX --disable-shared --enable-static --enable-gpl --enable-version3 --extra-libs=-static --extra-cflags=-static-libgcc" "--enable-zlib --enable-cross-compile --cross-prefix=$TOOLCHAIN/bin/$TARGET- --target-os=linux --cc=$TARGET-gcc --host-cc=$TARGET-gcc --arch=armv7-a --disable-asm --disable-debug --enable-libvorbis --enable-libx264 --enable-libspeex"
zinstall $pkg[ffmpeg]


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
