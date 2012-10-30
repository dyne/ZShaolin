# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

# configure the logfile
LOGS=build.log
rm -f $LOGS; touch $LOGS


# download and decompress all sources
prepare_sources


compile alsa-lib default "--disable-shared --enable-static --with-softfloat --without-libdl --without-librt --disable-python"
zinstall alsa-lib

compile alsa-utils default "--disable-shared --enable-static --without-librt --disable-alsaconf --disable-xmlto"
{ test -r alsa-utils.installed } || {
act "Installing alsa-utils"
cp alsa-utils/alsamixer/alsamixer \
 alsa-utils/alsactl/alsactl \
 alsa-utils/alsaloop/alsaloop \
 alsa-utils/amidi/amidi \
 alsa-utils/aplay/aplay \
 alsa-utils/amixer/amixer \
 alsa-utils/speaker-test/speaker-test \
 alsa-utils/seq/aconnect/aconnect \
 alsa-utils/seq/aplaymidi/aplaymidi \
 alsa-utils/seq/aplaymidi/arecordmidi \
 alsa-utils/seq/aseqdump/aseqdump \
 ${PREFIX}/bin
touch alsa-utils.installed
}
