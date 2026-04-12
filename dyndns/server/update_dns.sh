#!/bin/bash
##########################################################
# Script by github.com/serbanpaun/
# Command line format is:
# update_dns.sh DYNHOST_IPADDRESS
# e.g: update_dns.sh JOHNDOE_127.0.0.1
#      This will create the record:
#      JOHNDOE.DYNDNSZONE A 127.0.0.1
##########################################################
# Version 2.0 - 2026-04-12
# Check if parameters are provided
[ -z "$1" ] && { echo "No parameter. Exiting"; exit 1; }

# Extract the parameters
RAW="$1"
DYNHOST=$(echo "$RAW" | cut -d'_' -f1)
# This will be blank if not provided (replaced by 127.0.0.1 later)
IPADDRESS=$(echo "$RAW" | awk -F'_' 'NF>1 {print $2}')

# Create logs directory if it doesn't exist
LOGDIR="logs" # no trailing slash
[ ! -d "$LOGDIR" ] && mkdir "$LOGDIR"

# Source environment variables
# This file should contain:
# DBHOST="your_db_host"
# DBNAME="your_db_name"
# DBUSERNAME="your_db_username"
# DBPASSWORD="your_db_password"
# DNSSERVER="your_authoritative_dns_server"
# DNSKEYFILE="path_to_your_dns_key_file" # Generate key file with: tsig-keygen -a HMAC-SHA512 KEYNAME > /etc/bind/KEYNAME.key
# DYNUSER="username_for_db_entry"
# DYNDNSZONE="your_dynamic_dns_zone" # e.g. mydynamicdns.tld
########################################
SCRIPTPATH=`dirname $(realpath $0)`
source $SCRIPTPATH/.update_dns.env

# Random sleep (optional, to prevent multiple updates at the same time if you have many clients)
#SLEEP=$[ ( $RANDOM % 60 )  + 1 ]s
#echo "Sleeping for ${SLEEP} seconds... "
#sleep $SLEEP

##### Defining variables #####
# Define color variable
COLORS=1

# Parameters sent to the script
USER_NAME="$DYNHOST.$DYNDNSZONE"

# check if dig, rndc and nsupdate commands exist
DIG=$(which dig)
RNDC=$(which rndc)
NSUPDATE=$(which nsupdate)
if [ -z "$DIG" ] || [ -z "$RNDC" ] || [ -z "$NSUPDATE" ]; then
	echo -e "${RED}Error: Prerequisistes not met. Please install bind-utils or dnsutils.${NC}"
	exit 1
fi

# DNS record Time To Live
TTL="60"

colors() {
	NC='\033[0m'
	RED='\033[00;31m'
	GREEN='\033[00;32m'
	YELLOW='\033[00;33m'
	BLUE='\033[00;34m'
	PURPLE='\033[00;35m'
	CYAN='\033[00;36m'
	LIGHTGRAY='\033[00;37m'
	LRED='\033[01;31m'
	LGREEN='\033[01;32m'
	LYELLOW='\033[01;33m'
	LBLUE='\033[01;34m'
	LPURPLE='\033[01;35m'
	LCYAN='\033[01;36m'
	WHITE='\033[01;37m'
}
##### Customization ends here #####

# Color script - optional
[ "$COLORS" -eq 1 ] && colors

checkip() {
	PREIP=`$DIG +short $USER_NAME`
	echo -e "${GREEN}Current IP is: ${PREIP}${NC}"
}
# Optional, for debugging purposes.
# Comment the echoes if you don't want any output
echo -e "${RED}DYNHOST${NC} is ${DYNHOST}"
echo -e "${YELLOW}IP ADDRESS${NC} is ${IPADDRESS}"
echo -e "${PURPLE}USER_NAME${NC} IS ${USER_NAME}"

checkip
if [ -z $PREIP ]
  then
    echo $PREIP; echo "${RED}DNS error // Could not get IP address${NC}";
# Optional exit if not found
#    exit;
  else
    echo -e "${USER_NAME} = ${PREIP} // ${GREEN}DNS check OK${NC}";
fi

if [ -z $IPADDRESS ]; then
	echo -e "${LCYAN}No IP was specified. Will default to 127.0.0.1${NC}";
	IPADDRESS="127.0.0.1";
fi

### Output of IP Address set
echo -e "${LYELLOW}IP is $IPADDRESS${NC}"
sleep 1
# Record to be added to DNS
RECORD=" $USER_NAME. $TTL A $IPADDRESS"

# Small debugging messages
echo -ne "${LYELLOW}Will update ${DYNDNSZONE} with:${NC} "
echo -e "${LYELLOW}${RECORD}${NC}"

### UNFREEZE ZONE TO ALLOW UPDATES ###
echo -e "${LCYAN}Unfreezing ${DYNDNSZONE}${NC}"
$RNDC unfreeze ${DYNDNSZONE}

### Update DNS record using nsupdate and the DNS KEY
TIMESTAMP=$(date +"%d %B %Y %T")

# Output the nsupdate commands to a log file for debugging and also execute them
echo "
; ${TIMESTAMP}
server ${DNSSERVER}
zone ${DYNDNSZONE}
update delete ${USER_NAME}.
update add ${RECORD}
show
send" > ${LOGDIR}/${USER_NAME}.log
# Update the DNS record
$NSUPDATE -L0 -k $DNSKEYFILE ${LOGDIR}/${USER_NAME}.log 2&>1

# Update the database with the new IP address and TIMESTAMP
docker exec -t db mariadb -u$DBUSERNAME -p$DBPASSWORD $DBNAME -e " \
	INSERT INTO entries (USERNAME, DNS_NAME, IP_ADDRESS, FIRSTUPDATE) \
	VALUES ('$DYNUSER', '$USER_NAME', '$IPADDRESS', CURRENT_TIMESTAMP) \
	ON DUPLICATE KEY UPDATE IP_ADDRESS = VALUES(IP_ADDRESS), \
	FIRSTUPDATE = VALUES(FIRSTUPDATE);"

checkip
### Freeze the zone again to prevent updates
echo -ne "${CYAN}Freezing zone to prevent updates... ${NC}"
$RNDC freeze $DYNDNSZONE

# Optional echo
echo -e "${GREEN}DONE!${NC}"
