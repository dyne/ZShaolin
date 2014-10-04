# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

# download and decompress all sources
prepare_sources

vim_cv_toupper_broken=no \
vim_cv_terminfo=yes \
vim_cv_tty_group=world \
vim_cv_getcwd_broken=no \
vim_cv_stat_ignores_slash=yes \
vim_cv_memmove_handles_overlap=yes \
ac_cv_sizeof_int=4 \
ac_cv_c_uint32_t=yes \
compile vim default "--with-features=huge --without-x --without-gnome --with-tlib=ncurses --disable-xsmp --disable-sysmouse --disable-gpm --disable-acl --disable-xim --disable-gui"
zinstall vim

#compile emacs default "--with-x-toolkit=no --without-x --without-sound --without-xml2 --without-gnutls --without-dbus --with-crt-dir=$ZHOME/toolchains/crosstool-ng/x-tools/arm-dyne-linux-gnueabi/sysroot/usr/lib"


# mandoc
compile mdocml preconv mandoc demandoc
# nomake to build only preconv mandoc demandoc
#{ test -r mdocml.done } || {
#  pushd mdocml
#  make preconv mandoc demandoc
#  { test $? = 0 } && { touch ../mdocml.done }
#  popd
#}
{ test -r mdocml.installed } || {
  cp mdocml/preconv mdocml/mandoc mdocml/demandoc ${PREFIX}/bin
  cp mdocml/preconv.1 mdocml/mandoc.1 mdocml/demandoc.1 ${PREFIX}/share/man/man1
}

## doctools (for man pages)
cp mk.config.heirloom-doctools heirloom-doctools/mk.config
cat << EOF >> heirloom-doctools/mk.config
PREFIX=${PREFIX}
CC=static-cc
C++=static-c++
CFLAGS="${OPTIMIZATIONS}"
LDFLAGS="${LDFLAGS}"
EOF
pushd heirloom-doctools
make makefiles
make -C troff/libhnj
make -C troff/nroff.d
{ test $? = 0 } && { touch ../doctools.done }
popd
{ test -r doctools.installed } || {
 cp heirloom-doctools/troff/nroff.d/nroff \
 ${PREFIX}/bin
 }


