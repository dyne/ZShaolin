# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


# download and decompress all sources
prepare_sources


###########################################
## COMPILE PACKAGES:

## zlib
compile zlib "--prefix=$PREFIX --static"
zinstall zlib

## ncurses
compile ncurses default \
	"--enable-widec --enable-ext-colors --enable-ext-mouse --without-trace --without-tests --without-debug --disable-big-core"
zinstall ncurses
ln -sf $PREFIX/include/ncursesw/* $PREFIX/include/

## zsh
compile zsh default
zinstall zsh

## awk
compile gawk default
zinstall gawk

## sed
compile sed default
zinstall sed

## grep
compile grep default
zinstall grep

## diff
compile diffutils default
zinstall diffutils

## htop
compile htop default "--disable-native-affinity --enable-unicode"
zinstall htop

## netcat
compile netcat default
zinstall netcat

## nano
compile nano default 
zinstall nano

## openssl
# cp $pkg[openssl].Makefile $pkg[openssl]/Makefile
# compile $pkg[openssl] default
# zinstall $pkg[openssl]

# ## shellinabox
# { test ! -r $pkg[shellinabox].done } && {
#     cp $pkg[shellinabox].configure.ac $pkg[shellinabox]/configure.ac
#     cp $pkg[shellinabox].Makefile.am $pkg[shellinabox]/Makefile.am
#     cd $pkg[shellinabox] && autoreconf -i && cd ..
#     compile $pkg[shellinabox] default \
# 	"--disable-pam --enable-static --with-objcopy=$TARGET-objcopy"
# }
# zinstall $pkg[shellinabox]

# compile $pkg[dropbear] default # "" noinstal
# zinstall $pkg[dropbear]
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
{ test -r etc }   && {
    echo -n " etc";   rsync -dar etc $PREFIX/
    # zcompile the grmlrc script to gain loading speed
    zcompile $PREFIX/etc/grmlrc }
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

