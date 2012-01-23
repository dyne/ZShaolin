# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS

if [ "$1" = "clean" ]; then
    clean ncurses-5.9
    clean zsh-4.3.15
    clean gawk-4.0.0
    clean sed-4.2.1
    clean grep-2.9
    clean diffutils-3.2
    return 0
fi

###########################################
## COMPILE PACKAGES:

## ncurses
compile ncurses-5.9 default "--enable-widec --enable-ext-colors --enable-ext-mouse"

## zsh
compile zsh-4.3.15 default # "--disable-locale"

## awk
compile gawk-4.0.0 default

## sed
compile sed-4.2.1 default

## grep
compile grep-2.9 default

## diff
compile diffutils-3.2 default


return 0