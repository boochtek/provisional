#!/bin/sh


## Make sure sudo is installed
apt-get install sudo


## Require Root Password

# By default, sudo requires a user to type in their own password in order to run a command.
# For added security, we prefer to use a different password to run commands as root.
# This way, if a user password is compromised, the attacker cannot run commands as root without additional work.

cat > /etc/sudoers.d/require_root_password << EOF
# Require root password (instead of the user's own password).
Defaults        rootpw
EOF
chmod 440 /etc/sudoers.d/require_root_password
visudo -c -f /etc/sudoers.d/require_root_password


## Environment

# The sudo command ensures that certain environment variables are not carried over, to prevent security problems.
# We need to tweak the set of environment variables a bit.

cat > /etc/sudoers.d/environment << EOF
# Set $HOME to the target user's home directory. Allows mysql clients to find root's $HOME/.my.cnf config file automatically.
Defaults        always_set_home

# Reset all environment variables, except the ones we explicitly list.
Defaults        env_reset
Defaults        env_keep = "PATH MAIL PS1 PS2 HOSTNAME HISTSIZE \
                           LS_COLORS COLORS INPUTRC TZ \
                           LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION \
                           LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC \
                           LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS"
EOF
chmod 440 /etc/sudoers.d/environment
visudo -c -f /etc/sudoers.d/environment


## Package Management

# Since installing and updating software from standard repositories is a common admin task with low security risk,
# we'll allow it without requiring a password.

touch /etc/sudoers.d/package_management
cat > /etc/sudoers.d/package_management << EOF
# Admin users may install and update software packages without having to supply a password.
Cmnd_Alias      PACKAGE_INFO    = /usr/bin/apt-get install *, /usr/bin/apt-get check, \
                                  /usr/bin/apt-cache search *, /usr/bin/apt-cache show *, /usr/bin/apt-cache showpkg *, \
                                  /usr/bin/aptitude search *, /usr/bin/aptitude show *, /usr/bin/aptitude changelog *
Cmnd_Alias      PACKAGE_INSTALL = /usr/bin/apt-get install *, \
                                  /usr/bin/aptitude install *, /usr/bin/aptitude reinstall *
Cmnd_Alias      PACKAGE_UPDATE  = /usr/bin/apt-get update, /usr/bin/apt-get upgrade, \
                                  /usr/bin/aptitude update, /usr/bin/aptitude safe-upgrade
Cmnd_Alias      PACKAGE_CLEAN =   /usr/bin/apt-get autoremove, /usr/bin/apt-get clean, /usr/bin/apt-get autoclean, \
                                  /usr/bin/aptitude clean, /usr/bin/aptitude autoclean
%sudo           ALL = NOPASSWD: PACKAGE_INFO, PACKAGE_INSTALL, PACKAGE_UPDATE, PACKAGE_CLEAN
EOF
chmod 440 /etc/sudoers.d/package_management
visudo -c -f /etc/sudoers.d/package_management
