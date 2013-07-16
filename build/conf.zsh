# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# build packages in order
pkgs=(
    busybox
    system
    media
    sound
    lang
    toys

#    daemons
)

{ test "$module" = "list" } && {
  notice "Build modules: $pkgs"; return 0 }

{ test "$module" = "all" } || { pkgs=("$module") }

{ test -r $module } || { 
  error "Module not found: $module"
  return 1 }

case $operation in
    clean)
	for i in $pkgs; do
	    notice "Cleaning module: $i"
	    pushd $i
	    for s in `cat Sources | awk '!/^#/ { print $1 }'`; do
		act "clean $s"
		rm -rf ${s} ${s}.done ${s}.installed
		{ test -r extract } && { rm -rf extract }
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
	    notice "Copying scripts and configurations present in module $i"
	    { test -r ${i}/bin }   && { rsync -dar ${i}/bin   $PREFIX/ }
	    { test -r ${i}/etc }   && { rsync -dar ${i}/etc   $PREFIX/ }
	    { test -r ${i}/var }   && { rsync -dar ${i}/var   $PREFIX/ }
	    { test -r ${i}/share } && { rsync -dar ${i}/share $PREFIX/ }
    	done


    	notice "Build completed, summary:"
    	for i in $pkgs; do
	    notice "$i module"
	    summary=`find $ZHOME/build/$i -name "*.done"`
	    summary+="\n"
	    summary+=`find $ZHOME/build/$i -name "*.installed"`
	    echo ${summary} | sort
    	done
	;;
esac
