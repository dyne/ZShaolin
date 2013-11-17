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
    act "compiling lua"
    pushd lua/src
    for s in `find . -name '*.c'`; do
        { test -r ${s%.*}.o } || {
	${ZTARGET}-gcc ${=CFLAGS} -DLUA_USE_POSIX -DLUA_COMPAT_ALL -c ${s} }; done
    luas=`find . -name '*.o' | grep -v luac.o`
    ${ZTARGET}-gcc -o lua ${=CFLAGS} ${=luas} ${=LDFLAGS} -lncursesw -lm
    { test $? = 0 } && { 
	touch ../../lua.done
	notice "lua compiled"
    }
    popd
}
{ test -f lua.done } && {
    act "installing lua"
    cp lua/src/lua $PREFIX/bin/
    cp lua/doc/lua.1 $PREFIX/share/man/man1
    notice "lua installed"
}

## Perl
{ test -r perl.done } || {
    act "downloading PerlAPK" | tee -a $LOGS
    mkdir -p perl
    curl -q http://perl-android-apk.googlecode.com/files/PerlAPK.apk -o perl/PerlAPK.apk
    pushd perl
    unzip PerlAPK.apk
    pushd res/raw
    unzip -q perl_r9.zip
    unzip -q perl_extras_r7.zip
    mkdir -p $PREFIX/lib/perl
    mv perl/perl $PREFIX/bin
    mv perl/* $PREFIX/lib/perl/
    popd; popd
    touch perl.done
    notice "Perl installed"
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
