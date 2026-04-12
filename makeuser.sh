#!/bin/sh
#########################################################
# Interactive script for FTP user creation
# Customizable options:
# username, comment, login shell
# Password is randomly generated during runtime
# Homedir is set to /ftp/<USERNAME>
##########################################################
# useradd -N -c "OPTIONAL COMMENT" -d /ftp/<USERNAME> -g sftponly -s /sbin/nologin <USERNAME>

function check_status {
        case $? in
                        1)
                        echo "Aborted";
                        exit;;
        esac
}

mk_shell=$(whiptail --clear --backtitle "Select login shell" --title "Login shell" --menu "" 15 40 8 \
1 "Restricted /sbin/nologin (default)" \
2 "Standard /bin/bash" \
3 "Custom Login Shell" \
2>&1 >/dev/tty)

clear
case $mk_shell in
        1)
                mk_shell="/sbin/nologin"
                ;;
        2)
                mk_shell="/bin/bash"
                ;;
        3)
                mk_shell=$(whiptail --backtitle "Enter user login shell" --title "Login shell" --inputbox "Shell: " 10 30 2>&1 >/dev/tty)
                check_status
                ;;
        *)
                echo "Aborted";
                exit
                ;;
esac

function getusername {
        mk_username=$(whiptail --backtitle "Enter username" --title "FTP Username" --inputbox "Username:" 10 40 2>&1 >/dev/tty)
        check_status;
        if [ -n "$(getent passwd $mk_username)" ];
        then
                whiptail --title "FTP Username" --msgbox "User $mk_username already exists" 10 40 2>&1 >/dev/tty
                getusername
        else
                whiptail --title "FTP Username" --msgbox "User $mk_username is valid." 10 40 2>&1 >/dev/tty
        fi
}
getusername

mk_homedir="/ftp/$mk_username/"
# We do not allow homedir customization
# Comment out below lines to allow it.
# mk_homedir=$(whiptail --backtitle "Home directory for FTP user" --title "Home directory" --inputbox "Homedir (default is /ftp/<USERNAME>):" 10 60 /ftp/$mk_username 2>&1 >/dev/tty)
# check_status;
mk_comment=$(whiptail --backtitle "Enter the name of requester and ticket number" --title "Requester name and ticket number" --inputbox "Comment: " 10 60 2>&1 >/dev/tty)
check_status;

clear;
if ! (whiptail --title "FTP User creation" --yesno " User:          $mk_username\nLogin shell:   $mk_shell\nComment:       $mk_comment\nHomedir:       $mk_homedir\n\n\nDo you confirm the data?" 15 60 2>&1 >/dev/tty); then
                $(basename $0) && exit
        else
                echo "Moving forward..."
fi

# Create directories and permissions
mkdir -p $mk_homedir;
useradd -N -c "$mk_comment" -d $mk_homedir -g sftponly -s $mk_shell $mk_username
echo "User $mk_username created"
echo -n "Setting owner and permissions... "
chown $mk_username:sftponly $mk_homedir
chmod 700 $mk_homedir
echo "DONE"

# Generate random password and set it
genrnd=`</dev/urandom tr -dc '12345!@#$%abcdefghijklmnpqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ' | head -c16`
echo "Password will be set to $genrnd"
echo $genrnd | passwd --stdin $mk_username

# Cleaning up variables
unset genrnd
unset mk_username
unset mk_shell
unset mk_homedir
unset mk_comment
