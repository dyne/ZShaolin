# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

# packages
typeset -A pkg
pkg=(
    zlib zlib-1.2.5
    busybox busybox-1.19.3
    ncurses ncurses-5.9
    zsh zsh-4.3.15
    gawk gawk-4.0.0
    sed sed-4.2.1
    grep grep-2.9
    diffutils diffutils-3.2
    openssl openssl-1.0.0g
    libogg  libogg-1.3.0
)


if [ "$1" = "clean" ]; then
    for p in $pkg; do
	clean $p
    done
    return 0
fi

###########################################
## COMPILE PACKAGES:

## zlib
compile $pkg[zlib] "--prefix=$PREFIX --static"

## openssl
cp Makefile.openssl openssl-1.0.0g/Makefile
compile $pkg[openssl]

    
## ncurses
compile $pkg[ncurses] default "--enable-widec --enable-ext-colors --enable-ext-mouse"
ln -sf $PREFIX/include/ncursesw/* $PREFIX/include/

## zsh
compile $pkg[zsh] default

## awk
compile $pkg[gawk] default

## sed
compile $pkg[sed] default

## grep
compile $pkg[grep] default

## diff
compile $pkg[diffutils] default

## libogg
compile $pkg[libogg] default "--disable-shared --enable-static --with-pic=no"

# TODO busybox by hand for now
# if ! [ -r $pkg[busybox].done ]; then
#     cp -v $pkg[busybox].conf $pkg[busybox]/.config
#     echo "Compiling $pkg[busybox]"; cd $pkg[busybox]
#     CFLAGS="$CFLAGS $extracflags" CPPFLAGS="$CPPFLAGS" \
# 	CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
# 	make oldconfig && make && make install
#     cd -; touch $pkg[busybox].done
# fi
