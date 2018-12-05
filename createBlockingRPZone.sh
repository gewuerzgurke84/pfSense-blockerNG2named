#!/bin/sh

#############################################################
# This scripts transforms the pfBlockerNG DNS Blacklist     #
# to a custom named config, that can be included            #
#############################################################
# Documentation can be found here:                          #
# https://github.com/gewuerzgurke84/pfSense-blockerNG2named #
#############################################################

#
# Source Directoy: Directory holding pfBlockerNG feeds
#
sourceFilePattern="/var/db/pfblockerng/dnsbl/*.txt"

#
# Whitelist File: Never point zones from this whitelist to blocklist
#
whitelistFile="/root/createBlockingRPZoneWhitelist.txt"

#
# Destination Directories: Destination bind/named zone file
#
destZoneFilenameInChroot="/cf/named/etc/namedb/fuck.ads.zone"

#
# Destination Virtual IP (please use the same Virtual IP as configured in pfBlockerNG)
#
destVIP=10.10.10.1

#
# Restart named (Y/N)
#
restartNamed="N"

#
# Write zone file
#
echo "# Creating zone file ($destZoneFilenameInChroot)"
cat > $destZoneFilenameInChroot <<EOF
\$TTL     60
@ IN SOA        localhost. root.localhost. (
    2015082801   ; serial number YYMMDDNN
         28800   ; refresh 8 hours
          7200   ; retry 2 hours
        864000   ; expire 10 days
         86400 ) ; min ttl 1 day
     NS localhost.

localhost       A       127.0.0.1
EOF

#
# Clear
#
echo > /tmp/.pfBlockerToBind.1

#
# Collect zones and ensure bind compatibility
#
echo "# Collecting configured pfBlockerNG DNS Blacklist Files ($sourceFilePattern)"
for blockFile in $sourceFilePattern
do
        echo "## Processing $blockFile"
        # Format of file is "local-data: "<zone> IN a <virtual dnsblip>""        
        # We'll make zones bind compatible by removing "_" and "@" and transforming them
        cat $blockFile | cut -d\" -f2 | grep -v _ | grep -v "@" |grep $destVIP >> /tmp/.pfBlockerToBind.1        
done

#
# Remove entries from whitelist (regexp)
#
if [ -f "$whitelistFile" ]; then
    echo "# Apply whitelist ($whitelistFile)"
    while read line
    do 
        if [ ! -f "/tmp/.pfBlockerToBind.2" ]; then
            cat /tmp/.pfBlockerToBind.1 |egrep -v $line > /tmp/.pfBlockerToBind.2
        else
            cat /tmp/.pfBlockerToBind.2 |egrep -v $line > /tmp/.pfBlockerToBind.n
            mv /tmp/.pfBlockerToBind.n /tmp/.pfBlockerToBind.2
        fi
    done < $whitelistFile    
else
    echo "# Whitelist not found ($whitelistFile)"
fi
    
#
# Build resulting RP zone file
#
echo "# Build RP Zone File"   
cat /tmp/.pfBlockerToBind.2 >> $destZoneFilenameInChroot     

#
# Cleanup
#        
rm /tmp/.pfBlockerToBind.1
rm /tmp/.pfBlockerToBind.2

#
# Restart named
# 
if [ "$restartNamed" == "Y" ]; then
    echo "# Restarting named"
    service named.sh restart
fi

echo "# Finished"
