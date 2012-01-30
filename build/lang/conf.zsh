# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

# packages
typeset -A pkg
pkg=(
    ruby ruby-1.9.2-p290
    lua lua-5.2.0
)


if [ "$1" = "clean" ]; then
    for p in $pkg; do
	clean $p
    done
    return 0
fi

###########################################
## COMPILE PACKAGES:


## lua
{ test ! -r $pkg[lua].done } && {
    echo "Compiling $pkg[lua]" | tee -a ../$LOGS
    make -C $pkg[lua] posix TARGET=$TARGET MYCFLAGS="$CFLAGS" MYLDFLAGS="$LDFLAGS" \
	>> $LOGS
    { test $? = 0 } && { touch $pkg[lua].done }
}
{ test -f $pkg[lua].done } && {
    echo "Installing $pkg[lua]" | tee -a ../$LOGS
    cp $pkg[lua]/src/lua $PREFIX/bin/
    cp $pkg[lua]/src/luac $PREFIX/bin/
    cp $pkg[lua]/doc/lua.1 $PREFIX/share/man/man1
    cp $pkg[lua]/doc/luac.1 $PREFIX/share/man/man1
}

## ruby
# if ! [ -r $pkg[ruby].done ]; then
#     compile $pkg[ruby] default "--with-static-linked-ext=yes" nomake
#     make -C $pkg[ruby] ruby
#     cd $pkg[ruby]
#     CC="$TARGET-gcc" AR="$TARGET-ar" RANLIB="$TARGET-ranlib" LD="$TARGET-ld" \
# 	CFLAGS="-Os -O2 -fPIC -mfloat-abi=softfp -march=armv7-a -mtune=cortex-a8 -I$TOOLCHAIN/$TARGET/sysroot/usr/include -I$PREFIX/include" CXXFLAGS=$CFLAGS CPPFLAGS="-I$PREFIX/include" \
# 	LDFLAGS="-L$TOOLCHAIN/$TARGET/sysroot/lib -L$TOOLCHAIN/$TARGET/sysroot/usr/lib -L$PREFIX/lib -L$PREFIX/usr/lib" \
# 	./configure --host=$TARGET --prefix=$PREFIX
#     CC="$TARGET-gcc" AR="$TARGET-ar" RANLIB="$TARGET-ranlib" LD="$TARGET-ld" \
# 	CFLAGS="-Os -O2 -fPIC -mfloat-abi=softfp -march=armv7-a -mtune=cortex-a8 -I$TOOLCHAIN/$TARGET/sysroot/usr/include -I$PREFIX/include" CXXFLAGS=$CFLAGS CPPFLAGS="-I$PREFIX/include" \
# 	LDFLAGS="-L$TOOLCHAIN/$TARGET/sysroot/lib -L$TOOLCHAIN/$TARGET/sysroot/usr/lib -L$PREFIX/lib -L$PREFIX/usr/lib" \
# 	make
#     cd ..
# else
#     cp $pkg[ruby]/ruby $PREFIX/bin/
#     mkdir -p $PREFIX/ruby/bin
#     cp -ra $pkg[ruby]/bin/* $PREFIX/ruby/bin/
# fi