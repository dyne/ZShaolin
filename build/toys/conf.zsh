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
