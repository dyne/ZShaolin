# ZShaolin build script
# (C) 2012 Denis Roio - GNU GPL v3
# refer to zmake for license details

REPO="http://files.dyne.org/zshaolin/packages"
prepare_sources

notice "Installing packages in sysroot..."
rsync -ra extract/system/* ${PREFIX}/