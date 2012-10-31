# ZShaolin busybox build
# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


# download and decompress all sources
prepare_sources

cp .config.full busybox/.config
notice "Proceed compiling busybox by hand:"
act "cd build/busybox/busybox && make && make install"
act "cp busybox ../busybox.bin"
act "cp -ra _install $ZHOME/sysroot/busybox"

