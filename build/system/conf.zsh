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
    ncurses ncurses-5.9
    zsh zsh-4.3.15
    gawk gawk-4.0.0
    sed sed-4.2.1
    grep grep-2.9
    diffutils diffutils-3.2
    htop htop-1.0
    netcat netcat-0.7.1
    nano nano-2.2.6
    openssl openssl-1.0.0g
    shellinabox shellinabox-2.10
    dropbear dropbear-2011.54
)


if [ "$1" = "clean" ]; then
    for p in $pkg; do
	clean $p
    done
    return 0
fi

## make sure basic directories exist
mkdir -p $PREFIX/sbin
mkdir -p $PREFIX/bin

###########################################
## COMPILE PACKAGES:

## zlib
compile $pkg[zlib] "--prefix=$PREFIX --static"
zinstall $pkg[zlib]

## ncurses
compile $pkg[ncurses] default "--enable-widec --enable-ext-colors --enable-ext-mouse"
zinstall $pkg[ncurses]
ln -sf $PREFIX/include/ncursesw/* $PREFIX/include/

## zsh
compile $pkg[zsh] default
zinstall $pkg[zsh]

## awk
compile $pkg[gawk] default
zinstall $pkg[gawk]

## sed
compile $pkg[sed] default
zinstall $pkg[sed]

## grep
compile $pkg[grep] default
zinstall $pkg[grep]

## diff
compile $pkg[diffutils] default
zinstall $pkg[diffutils]

## htop
compile $pkg[htop] default "--disable-native-affinity --enable-unicode"
zinstall $pkg[htop]

## netcat
compile $pkg[netcat] default
zinstall $pkg[netcat]

## nano
compile $pkg[nano] default 
zinstall $pkg[nano]

## openssl
cp $pkg[openssl].Makefile $pkg[openssl]/Makefile
compile $pkg[openssl] default
zinstall $pkg[openssl]

## shellinabox
{ test ! -r $pkg[shellinabox].done } && {
    cp $pkg[shellinabox].configure.ac $pkg[shellinabox]/configure.ac
    cp $pkg[shellinabox].Makefile.am $pkg[shellinabox]/Makefile.am
    cd $pkg[shellinabox] && autoreconf -i && cd ..
    compile $pkg[shellinabox] default \
	"--disable-pam --enable-static --with-objcopy=$TARGET-objcopy"
}
zinstall $pkg[shellinabox]

compile $pkg[dropbear] default # "" noinstal
zinstall $pkg[dropbear]
# # manual install
# { test -r $pkg[dropbear].done } && {
#     cp $pkg[dropbear]/dropbear        $PREFIX/sbin/
#     cp $pkg[dropbear]/dbclient        $PREFIX/bin/
#     cp $pkg[dropbear]/dropbearconvert $PREFIX/bin/
#     cp $pkg[dropbear]/dropbearkey     $PREFIX/bin/
#     mkdir -p $PREFIX/share/man/man1
#     mkdir -p $PREFIX/share/man/man8
#     cp $pkg[dropbear]/*.1 $PREFIX/share/man/man1;
#     cp $pkg[dropbear]/*.8 $PREFIX/share/man/man8;
# }

###########################################
## COPY CONFIGURATIONS AND SCRIPTS

echo "Copying scripts and configurations..."
{ test -r bin }   && { echo -n " bin";   rsync -dar bin $PREFIX/ }
{ test -r etc }   && { echo -n " etc";   rsync -dar etc $PREFIX/ }
{ test -r var }   && { echo -n " var";   rsync -dar var $PREFIX/ }
{ test -r share } && { echo -n " share"; rsync -dar share $PREFIX/ }
echo


# TODO busybox by hand for now
# if ! [ -r $pkg[busybox].done ]; then
#     cp -v $pkg[busybox].conf $pkg[busybox]/.config
#     echo "Compiling $pkg[busybox]"; cd $pkg[busybox]
#     CFLAGS="$CFLAGS $extracflags" CPPFLAGS="$CPPFLAGS" \
# 	CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
# 	make oldconfig && make && make install
#     cd -; touch $pkg[busybox].done
# fi

# OpenSSL works but not needed for now

