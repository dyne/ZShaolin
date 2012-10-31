# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


# download and decompress all sources
prepare_sources

compile libcaca default "--disable-java --disable-cxx --disable-python --disable-ruby --enable-ncurses"
zinstall libcaca


pushd sl
${TARGET}-gcc ${=CFLAGS} -o sl sl.c ${=LDFLAGS} -lncursesw
{ test $? = 0 } && { touch ../sl.done }
popd
cp sl/sl ${PREFIX}/bin
notice "Steam Locomotive installed"
