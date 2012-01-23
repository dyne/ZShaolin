# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

BUSYBOX_SOURCES=busybox-1.19.3

if [ "$1" = "clean" ]; then
    cd $BUSYBOX_SOURCES
    touch ../build.log
    make clean >> ../build.log
    rm -f $BUSYBOX_SOURCES.done
    return 0
fi

if [ -r $BUSYBOX_SOURCES.done ]; then
    echo "$BUSYBOX_SOURCES.done :: already built, skipping compilation"
    return 0
fi

rm -f build.log

cd $BUSYBOX_SOURCES

CFLAGS="$CFLAGS $extracflags" \
    CPPFLAGS="$CPPFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    make > ../build.log

CFLAGS="$CFLAGS $extracflags" \
    CPPFLAGS="$CPPFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    make install >> ../build.log

cd -

touch $BUSYBOX_SOURCES.done
