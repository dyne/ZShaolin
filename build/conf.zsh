# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

   
if ! [ $2 ]; then
    echo "Target all sources with $1"
    for i in `ls -F | grep '.*/$'`; do
    	cd $ZHOME/build
	enter $i $@
    done
    return 0
fi


if [ -r $2/conf.zsh ]; then
    echo "target module '$2'"
    enter $2 $@
else   
    echo "nothing to build in $2"
fi
