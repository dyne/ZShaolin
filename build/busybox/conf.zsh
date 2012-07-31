# ZShaolin busybox build

bbox="busybox-1.19.3"

bboxtar="${bbox}.tar.bz2"

{ test -r ${bbox} } || {
   { test -r ${bboxtar} } || { wget ${REPO}/${bboxtar} }
   tar xfj ${bboxtar}
}

cp .config ${bbox}/.config

pushd ${bbox}
make
popd

