# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


# download and decompress all sources
prepare_sources


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
cat << EOF > heirloom-doctools/mk.config
PREFIX=${PREFIX}
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


