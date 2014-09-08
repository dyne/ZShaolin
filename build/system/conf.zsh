# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details


# download and decompress all sources
prepare_sources


###########################################
## COMPILE PACKAGES:


## zlib
compile zlib "--prefix=$PREFIX --static"
#zinstall zlib
{ test -r zlib.installed } || {
act "Installing ZLib"
mkdir -p $PREFIX/lib $PREFIX/include
cp zlib/libz.a $PREFIX/lib/
cp zlib/zlib.h zlib/zconf.h $PREFIX/include
touch zlib.installed
}

## ncurses
compile ncurses default "--enable-ext-mouse --without-trace --without-tests --without-debug --disable-big-core --enable-widec --enable-ext-colors"
zinstall ncurses
# create ncurses symlinks in PREFIX
pushd $PREFIX/include
ln -sf ncursesw/* .
popd
pushd $PREFIX/lib
ln -sf libncursesw.a libncurses.a 
ln -sf libncursesw.a libcurses.a 
popd

#compile zsh default
#zinstall zsh

## s-lang
notice "Building S-Lang"
{ test -r slang.done } || {
    pushd slang
    zconfigure default #  --disable-static
    { test $? = 0 } && { 
	pushd src && make static
	{ test $? = 0 } && { touch ../../slang.done }
	popd }
    popd }
zinstall slang install-static


## sed
compile sed default
zinstall sed

# awk
compile gawk default
zinstall gawk

## grep
compile grep default
zinstall grep

## file
compile file default
zinstall file

# less pager
compile less default
zinstall less

## diff
compile diffutils default
zinstall diffutils

## htop
compile htop default "--disable-native-affinity --enable-unicode"
zinstall htop

## nano
compile nano default 
zinstall nano

## most
notice "Building most"
{ test -r most.done } || {
    pushd most
    zconfigure default
    { test $? = 0 } && {
	gcc -Isrc -c src/chkslang.c -o src/objs/chkslang.o
	gcc src/objs/chkslang.o -o src/objs/chkslang
	zmake
	{ test $? = 0 } && { touch ../most.done }
    }
    popd
}
zinstall most

## wipe
compile	wipe default
{ test -r wipe.installed } || {
  act "Installing wipe"
  cp wipe/wipe ${PREFIX}/bin/
  cp wipe/wipe.1 ${PREFIX}/share/man/man1/
  touch wipe.installed
  act "Wipe installed."
}

## tmux
compile tmux default "--enable-static"
#pushd tmux
#zmake
zinstall tmux


return


###################
# experiments below

## libevent
compile libevent default
zinstall libevent
# ## shellinabox
# { test ! -r $pkg[shellinabox].done } && {
#     cp $pkg[shellinabox].configure.ac $pkg[shellinabox]/configure.ac
#     cp $pkg[shellinabox].Makefile.am $pkg[shellinabox]/Makefile.am
#     cd $pkg[shellinabox] && autoreconf -i && cd ..
#     compile $pkg[shellinabox] default \
# 	"--disable-pam --enable-static --with-objcopy=$TARGET-objcopy"
# }
# zinstall $pkg[shellinabox]



# TODO busybox by hand for now
# if ! [ -r $pkg[busybox].done ]; then
#     cp -v $pkg[busybox].conf $pkg[busybox]/.config
#     echo "Compiling $pkg[busybox]"; cd $pkg[busybox]
#     CFLAGS="$CFLAGS $extracflags" CPPFLAGS="$CPPFLAGS" \
# 	CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
# 	make oldconfig && make && make install
#     cd -; touch $pkg[busybox].done
# fi

