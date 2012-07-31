# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# build packages in order
pkgs=(
    system
    games
    media
    lang
#    daemons
)

if ! [ $2 ]; then
    notice "Target all sources with $1"
    for i in $pkgs; do
    	cd $ZHOME/build
	enter $i ${=@}
    done
    { test $1 = clean } && return 0
    notice "Build completed, summary:"
    for i in $pkgs; do
	find $ZHOME/build/$i -name "*.done" | sort
    done

    return 0
fi


if [ -r $2/conf.zsh ]; then
    act "Target module '$2'"
    enter $2 ${=@}
else   
    act "nothing to build in $2"
fi
