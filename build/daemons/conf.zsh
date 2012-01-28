# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

typeset -A pkg
pkg=(
    dropbear dropbear-2011.54
    libshout libshout-2.2.2
    icecast icecast--2.3.2
)

if [ "$1" = "clean" ]; then
    for p in $pkg; do
	clean $p
    done
    return 0
fi

###########################################
## COMPILE PACKAGES:

compile $pkg[dropbear] default "" noinstall
# manual install
if [ -r $pkg[dropbear].done ]; then
    cd $pkg[dropbear]; cp dropbear $PREFIX/sbin
    cp dbclient dropbearconvert dropbearkey $PREFIX/bin
    cp dbclient.1 $PREFIX/share/man/man1;
    cd $PREFIX/share/man/man1; ln -sf dbclient.1 ssh.1
    cd $PREFIX/sbin; ln -sf dropbear sshd
    cd ../bin; ln -sf dbclient ssh; ln -sf dropbearkey ssh-keygen
    cd $ZHOME; fi


compile $pkg[libshout] default  "--disable-shared --enable-static --with-pic=no"

compile $pkg[icecast] default  "--disable-shared --enable-static --with-pic=no"


## deactivated packages below


# compile openssh-5.9p1 "--host=$TARGET --prefix=$APKPATH/system" "--disable-libutil --disable-utmp --disable-utmpx --with-sandbox=no --without-shadow --with-default-path=$APKPATH/system/bin --with-pid-dir=$APKPATH/system/var --with-privsep-path=$APKPATH/system/var " noinstall
# # install by hand
# if [ -r openssh-5.9p1.done ]; then
#     cd openssh-5.9p1
#     cp scp sftp sftp-server ssh ssh-add ssh-agent sshd ssh-keygen ${PREFIX}/bin
#     cd -
# fi

# compile shellinabox-2.10 default "--disable-pam --enable-static"
