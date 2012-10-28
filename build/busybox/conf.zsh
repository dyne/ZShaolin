# ZShaolin busybox build

bbox="busybox-git"

bboxtar="${bbox}.tar.bz2"

{ test -r ${bbox} } || {
   { test -r ${bboxtar} } || { wget ${REPO}/${bboxtar} }
   tar xfj ${bboxtar}
}

# cp .config ${bbox}/.config

#pushd ${bbox}
notice "Compiling Busybox"
make -C ${bbox}
act "Installing Busybox"
make -C ${bbox} install
cp ${bbox}/busybox .
cp -ra ${bbox}/_install $PREFIX/busybox
notice "-- Busybox done."
#popd

