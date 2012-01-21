

cd busybox-1.19.3
CFLAGS="$CFLAGS $extracflags" \
    CPPFLAGS="$CPPFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    make && make install
cd -