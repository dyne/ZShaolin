
# fundamental paths

export HOME=/data/data/org.dyne.zshaolin/files
export SYS=$HOME/system
export PATH=$SYS/bin:$SYS/bin/bbdir:$PATH
export MANPATH=$SYS/share/man
export SHELL="$SYS/bin/zsh"
export TERMINFO=$SYS/share/terminfo
export TERM=xterm-color

# set zsh to recognize these correctly

cd $HOME
echo "Hellcome in ZShaolin"
zsh
