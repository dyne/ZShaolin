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
if ! [ -r $pkg[lua].done ]; then
    cd $pkg[lua]
    make posix TARGET=$TARGET MYCFLAGS="$CFLAGS" MYLDFLAGS="$LDFLAGS"
    if [ $? = 0 ]; then
	cp src/lua src/luac $PREFIX/bin
	cp doc/lua.1 doc/luac.1 $PREFIX/share/man/man1
	touch ../$pkg[lua].done
    fi; cd -
fi

## ruby
compile $pkg[ruby] default "--with-static-linked-ext=yes" nomake
cd $pkg[ruby]; make ruby;
cp ruby $PREFIX/bin/
mkdir $PREFIX/ruby
cp -ra bin $PREFIX/ruby/bin
cd -
