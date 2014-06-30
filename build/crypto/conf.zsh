prepare_sources

# gnuTLS

compile gmp default
zinstall gmp

compile nettle default "--disable-shared --enable-static --disable-assembler"
zinstall nettle

compile libidn default
zinstall libidn

{ test -r gnutls.done } || {
notice "Building GNUtls"
pushd gnutls
zconfigure default "--disable-shared --enable-static --disable-crywrap --without-p11-kit"
zmake -C lib
{ test $? = 0 } && { touch ../gnutls.done }
popd }
{ test -r gnutls.installed } || {
pushd gnutls
zmake -C lib install
touch ../gnutls.installed
notice "GNUtls libraries correctly built and installed"
popd
}

compile libgpg-error default
zinstall libgpg-error

compile libgcrypt default
zinstall libgcrypt


compile pinentry default "--disable-pinentry-gtk --disable-pinentry-gtk2 --disable-pinentry-qt --disable-pinentry-qt4"
zinstall pinentry


compile gnupg default
zinstall gnupg


