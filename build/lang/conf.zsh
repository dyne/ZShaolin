# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

###########################################
## COMPILE PACKAGES:

prepare_sources

## lua
{ test ! -r lua.done } && {
    act "compiling lua" | tee -a ../$LOGS
    cp Makefile.lua lua/Makefile
    cp Makefile.lua.src lua/src/Makefile 
    CC="$TARGET-gcc" AR="$TARGET-ar" RANLIB="$TARGET-ranlib" LD="$TARGET-ld" \
	make -C lua posix TARGET=$TARGET MYCFLAGS="$CFLAGS" MYLDFLAGS="$LDFLAGS" \
	>> $LOGS
    { test $? = 0 } && { 
	touch lua.done
	notice "lua compiled"
    }
}
{ test -f lua.done } && {
    act "installing lua" | tee -a ../$LOGS
    cp lua/src/lua $PREFIX/bin/
    cp lua/src/luac $PREFIX/bin/
    cp lua/doc/lua.1 $PREFIX/share/man/man1
    cp lua/doc/luac.1 $PREFIX/share/man/man1
    notice "lua installed"
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
