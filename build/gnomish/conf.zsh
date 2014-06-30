prepare_sources

# compile libiconv default "--enable-relocatable --disable-shared --enable-static=yes"
{ test -r $PREFIX/lib/libiconv.a } || {
pushd libiconv
zconfigure default "--enable-relocatable --disable-shared --enable-static=yes"
make -k
make -k install
popd
}

# make libffi
compile libffi default "--disable-shared --enable-static --enable-portable-binary"
zinstall libffi

# make glib
compile glib default "--disable-shared --enable-static"
zinstall glib

# midnight commander
compile mc default
zinstall mc


return 



###################
# experiments below 

# bitlbee (should go in crypto rly)
compile bitlbee default
zinstall bitlbee


# rtorrent (libsigc++ and libtorrent)
sed -i 's@examples@@' libsigc++/Makefile.in
compile libsigc++ default "--disable-shared --enable-static"
zinstall libsigc++
compile libtorrent default "--disable-shared --enable-static --enable-aligned --with-kqueue=no"
zinstall libtorrent
# OK!

# rtorrent not working :^(
compile rtorrent default
zinstall rtorrent

return 
# python stuff below

compile expat default
zinstall expat


compile Python default "--build=x86_64-unknown-linux-gnu --disable-shared --with-system-expat --with-system-ffi --disable-ipv6"
zinstall Python

compile dstat default
zinstall dstat


