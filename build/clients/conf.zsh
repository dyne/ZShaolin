# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

# packages
typeset -A pkg
pkg=(
    jwhois jwhois-4.0
    curl curl-7.24.0
    htop htop-1.0
    netcat netcat-0.7.1
)


if [ "$1" = "clean" ]; then
    for p in $pkg; do
	clean $p
    done
    return 0
fi

###########################################
## COMPILE PACKAGES:

## jwhois
compile $pkg[jwhois] default

## curl
compile $pkg[curl] default

## htop
compile $pkg[htop] default "--disable-native-affinity --enable-unicode"

## netcat
compile $pkg[netcat] default

