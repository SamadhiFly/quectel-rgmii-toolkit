# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
[ -d /opt/usr/sbin ] && PATH=$PATH:/opt/usr/sbin
[ -d /opt/usr/bin ] && PATH=$PATH:/opt/usr/bin
[ -d /opt/sbin ] && PATH=$PATH:/opt/sbin
[ -d /opt/bin ] && PATH=$PATH:/opt/bin
[ -d /usrdata/root/bin ] && PATH=$PATH:/usrdata/root/bin
EDITOR="vi"			# needed for packages like cron, git-commit
[ "$TERM" ] || TERM="vt100"	# Basic terminal capab. For screen etc.

# Add /sbin & co to $PATH for the root user
[ "$HOME" != "/home/root" ] || PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin

# Set the prompt for bash and ash (no other shells known to be in use here)
[ -z "$PS1" ] || PS1='\u@\h:\w\$ '

if [ -d /etc/profile.d ]; then
	for i in /etc/profile.d/*.sh; do
		if [ -f $i -a -r $i ]; then
			. $i
		fi
	done
	unset i
fi

# Make sure we are on a serial console (i.e. the device used starts with
# /dev/tty[A-z]), otherwise we confuse e.g. the eclipse launcher which tries do
# use ssh
case $(tty 2>/dev/null) in
	/dev/tty[A-z]*) [ -x /usr/bin/resize ] && /usr/bin/resize >/dev/null;;
esac

# Function to remount file system as read-write
remount_rw() {
    mount -o remount,rw /
}

# Function to remount file system as read-only
remount_ro() {
    mount -o remount,ro /
}

export PATH PS1 OPIEDIR QPEDIR QTDIR EDITOR TERM

umask 022
