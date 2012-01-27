# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

# packages
typeset -A pkg
pkg=(
	sox sox-14.3.2
)


if [ "$1" = "clean" ]; then
    for p in $pkg; do
	clean $p
    done
    return 0
fi

###########################################
## COMPILE PACKAGES:

## imagemagick
compile $pkg[sox] default "--disable-shared"
