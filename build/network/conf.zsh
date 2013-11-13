# ZShaolin build script
# (C) 2013 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

prepare_sources

# make openssl static libraries
zndk-build openssl-static
rsync openssl-static/obj/local/armeabi/*.a $PREFIX/lib/
rsync -r openssl-static/include/openssl $PREFIX/include

# make openssh
zndk-build android-openssh
rsync android-openssh/libs/armeabi/* $PREFIX/bin
rsync android-openssh/obj/local/armeabi/libssh.a $PREFIX/lib
rsync android-openssh/jni/*.1 $PREFIX/share/man/man1/
mv $PREFIX/bin/client-ssh $PREFIX/bin/ssh

# make rsync
compile rsync default
zinstall rsync

# make git
notice "Building git"
pushd git
zconfigure default
{ test $? = 0 } && {
    make prefix=${APKPATH}/files/system
    make man prefix=${APKPATH}/files/system
    { test $? = 0 } && { touch ../git.done }
}
make install prefix=${APKPATH}/files/system NO_INSTALL_HARDLINKS=1
make install-man prefix=${APKPATH}/files/system NO_INSTALL_HARDLINKS=1
popd
