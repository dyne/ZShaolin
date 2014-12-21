# ZShaolin build script
# (C) 2013-2014 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

prepare_sources

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


# make openssl static libraries
zndk-build openssl-static
rsync openssl-static/obj/local/armeabi/*.a $PREFIX/lib/
rsync -r openssl-static/include/openssl $PREFIX/include

# make curl with ssl
{ test -r curl.done } || {
    cp curl_setup.h curl/lib/
    LIBS="$LIBS -ldl -lssl -lcrypto" compile curl default "--with-ssl=$PREFIX --disable-shared --enable-static"
}
zinstall curl
# manual
cp -v curl/lib/.libs/libcurl.a $PREFIX/lib


# make openssh
{ test -r android-openssh.done } || {
    cp openssh-config.h android-openssh/jni/config.h
    cp openssh-pathnames.h android-openssh/jni/pathnames.h
    cp openssh-session.c android-openssh/jni/session.c
    zndk-build android-openssh
    { test $? = 0 } && { 
	touch android-openssh.done
	rm -f android-openssh.installed }
}
{ test -r android-openssh.installed } || {
    rsync android-openssh/libs/armeabi/* $PREFIX/bin
    rsync android-openssh/obj/local/armeabi/libssh.a $PREFIX/lib
    rsync android-openssh/jni/*.1 $PREFIX/share/man/man1/
    rsync android-openssh/jni/*.5 $PREFIX/share/man/man5/
    rsync android-openssh/jni/*.8 $PREFIX/share/man/man8/
    mv $PREFIX/bin/client-ssh $PREFIX/bin/ssh
    mkdir -p $PREFIX/etc/ssh
    rsync android-openssh/jni/*_config $PREFIX/etc/ssh/
    touch android-openssh.installed
}

# make rsync
compile rsync default
zinstall rsync

# make git
notice "Building git"
cp -v git-read-cache.c git/read-cache.c
GIT_FLAGS=(prefix=${APKPATH}/files/system NO_INSTALL_HARDLINKS=1 NO_NSEC=1 NO_ICONV=1)
GIT_FLAGS+=(CURLDIR=$PREFIX OPENSSLDIR=$PREFIX)
GIT_FLAGS+=(NO_PERL=1 NO_PYTHON=1)
{ test -r git.done } || {
pushd git
autoconf

# -lssl
LIBS="$LIBS -lz -ldl -lcurl -lcrypto" \
 zconfigure default "--without-iconv --with-curl=$PREFIX --with-openssl=$PREFIX"

{ test $? = 0 } && {
    LIBS="$LIBS" make ${GIT_FLAGS}
    # for manuals by hand:
    # make man
    # make install-man
    pushd templates
    LIBS="$LIBS" make install ${GIT_FLAGS}
    popd
#    make man prefix=${APKPATH}/files/system
    touch ../git.done
}
popd
}

{ test -r git.installed } || {
pushd git
{ LIBS="$LIBS" make install ${GIT_FLAGS} } && {
  LIBS="$LIBS" make install-man ${GIT_FLAGS} } && {
  touch ../git.installed }
#make install-man prefix=${APKPATH}/files/system NO_INSTALL_HARDLINKS=1

# now fix all shellbangs in git's scripts. can't do that from config
# flags because of config checks conflicting with cross-compilation.
notice "Fixing shell bangs in git scripts"
gitshellscripts=`find $APKPATH/files/system/libexec/git-core -type f`
for i in ${(f)gitshellscripts}; do
    func "git: fixing shellbang for $i"
    file $i | grep -i 'posix shell script' > /dev/null
    { test $? = 0 } && { sed -i "s@^#!/bin/sh@#!env zsh@" $i }
done
popd
}

{ test -r mongoose.done } || {
  pushd mongoose
  static-cc -c mongoose.c
  static-cc -o mongoose mongoose.o examples/server.c  -I .
  [[ $? = 0 ]] && { touch ../mongoose.done }
  popd
}
{ test -r mongoose.installed } || {
  cp -v mongoose/mongoose $PREFIX/bin/
  touch mongoose.installed
}

compile ncurses default "--enable-ext-mouse --without-trace --without-tests --without-debug --disable-big-core --enable-widec --enable-ext-colors"
pushd ncurses
make -k
popd
zinstall ncurses
# create ncurses symlinks in PREFIX
pushd $PREFIX/include
ln -sf ncursesw/* .
popd
pushd $PREFIX/lib
ln -sf libncursesw.a libncurses.a
ln -sf libncursesw.a libcurses.a
popd
compile lynx default # "--with-screen=slang"
zinstall lynx

# file occupation visualizator
compile ncdu default
zinstall ncdu

# file recovery
compile libuuid default
zinstall libuuid

compile testdisk default
zinstall testdisk


notice "copy all binaries from NDK in system"
cp -v $PREFIX/bin/lynx $ZHOME/system/bin/
cp -v $PREFIX/bin/curl $ZHOME/system/bin/
cp -v $PREFIX/bin/ssh $ZHOME/system/bin/
cp -v $PREFIX/bin/ssh-keygen $ZHOME/system/bin/
cp -v $PREFIX/bin/scp $ZHOME/system/bin/
cp -v $PREFIX/bin/sshd $ZHOME/system/bin/
cp -v $PREFIX/bin/sftp $ZHOME/system/bin/
cp -v $PREFIX/bin/rsync $ZHOME/system/bin/
cp -v $PREFIX/bin/mongoose $ZHOME/system/bin/
cp -v $PREFIX/bin/fidentify $ZHOME/system/bin/
cp -v $PREFIX/bin/photorec $ZHOME/system/bin/
cp -v $PREFIX/bin/testdisk $ZHOME/system/bin/
rsync -r $PREFIX/share/man/* $ZHOME/system/share/man/




######
# experimental zone
return



#############################

## s-lang
notice "Building S-Lang"
{ test -r slang.done } || {
    pushd slang
    zconfigure "--host=arm-linux-gnueabi --prefix=$SYSROOT/usr" 
    { test $? = 0 } && {
        pushd src && make static
        { test $? = 0 } && { touch ../../slang.done }
        popd }
    popd }
zinstall slang install-static


CFLAGS+=" -DOPENSSL_NO_ECDH " \
compile lighttpd default "--enable-static --disable-shared --without-bzip2 --without-pcre --with-openssl"
zinstall lighttpd



