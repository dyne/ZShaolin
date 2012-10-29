# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# build packages in order
pkgs=(
    busybox
    system
    media
    lang
    toys
#    daemons
)


{ test "$module" = "all" } || { pkgs=("$module") }

case $operation in
	clean)
	for i in $pkgs; do
            notice "Cleaning module: $i"
	    pushd $i
	    for s in `cat Sources | awk '!/^#/ { print $1 }'`; do
                act "clean $s"
                rm -rf ${s} ${s}.done ${s}.installed
            done
            popd
        done
        notice "All clean now."
	;;
	*)
    		notice "Building module: $module"
    		for i in $pkgs; do
    			pushd $ZHOME/build
			enter $i ${=@}
			popd
    		done
    		notice "Build completed, summary:"
    		for i in $pkgs; do
			find $ZHOME/build/$i -name "*.done" | sort
    		done
	;;
esac
