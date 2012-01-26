# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

if [ "$1" = "clean" ]; then
    clean shellinabox-2.10
    return 0
fi

###########################################
## COMPILE PACKAGES:

compile openssh-5.9p1 "--host=$TARGET --prefix=$APKPATH/system" "--disable-libutil --disable-utmp --disable-utmpx --with-sandbox=no --without-shadow --with-default-path=$APKPATH/system/bin --with-pid-dir=$APKPATH/system/var --with-privsep-path=$APKPATH/system/var " noinstall
# install by hand
{ test -r openssh-5.9p1.done } && cd openssh-5.9p1 && cp scp sftp \
    sftp-server ssh ssh-add ssh-agent sshd ssh-keygen ${PREFIX}/bin

compile shellinabox-2.10 default "--disable-pam --enable-static"


return 0