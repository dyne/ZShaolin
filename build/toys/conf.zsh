# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


# download and decompress all sources
prepare_sources

compile libcaca default \
	 "--disable-java --disable-cxx --disable-python --disable-ruby \
	  --enable-ncurses --enable-slang"
zinstall libcaca


notice "Building steam locomotive"
{ test -r sl.done } || {	
    pushd sl  
    ${TARGET}-gcc ${=CFLAGS} -o sl sl.c ${=LDFLAGS} -lncursesw
    { test $? = 0 } && { touch ../sl.done }
    popd }
{ test -r sl.installed } || {
    cp sl/sl ${PREFIX}/bin
    notice "Steam Locomotive installed"
}

compile matanza default
zinstall matanza

compile curseofwar default
zinstall curseofwar

compile ctris default
{ test $? = 0 } && { pushd ctris
cp ctris $PREFIX/bin
mkdir -p $PREFIX/share/man/man6/
gunzip -d -c ctris.6.gz > $PREFIX/share/man/man6/ctris.6
popd }

compile cryptoslam default
{ test $? = 0 } && { cp cryptoslam/cryptoslam $PREFIX/bin }
