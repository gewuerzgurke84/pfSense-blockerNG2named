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
# Whitelist File: Never point zones from whitelist to blocklist
#
whitelistFile="/root/createBlockingZonefileWhitelist.txt"

#
# Destination Directories: Destination bind/named zone file
#
destZoneFilename="/etc/namedb/fuck.ads.zone"
destZoneFilenameInChroot="/cf/named/etc/namedb/fuck.ads.zone"
destZoneConfig="/etc/namedb/fuck.ads.conf"
destZoneConfigInChroot="/cf/named/etc/namedb/fuck.ads.conf"

#
# Destination Virtual IP (please use the same Virtual IP as configured in pfBlockerNG)
#
destVIP=10.10.10.1

#
# Restart named
#
restartNamed="N"


# Write zone file
echo "# Creating zone file ($destZoneFilenameInChroot)"
cat > $destZoneFilenameInChroot <<EOF
\$TTL     86400   ; one day
@ IN SOA fuck.ads. root.fuck.ads. (
    2015082801   ; serial number YYMMDDNN
         28800   ; refresh 8 hours
          7200   ; retry 2 hours
        864000   ; expire 10 days
         86400 ) ; min ttl 1 day
     NS fuck.ads.
@ IN A  $destVIP
* IN A  $destVIP
EOF

# Clear destination zoneFile
echo > $destZoneConfigInChroot
# Collect
echo "# Collecting configured pfBlockerNG DNS Blacklist Files ($sourceFilePattern)"
for blockFile in $sourceFilePattern
do
        # Format of file is "local-data: "<zone> IN a <virtual dnsblip>""
        # Target must be bind compatible (remove domains with underscore)
        echo "## Processing ($blockFile)"
        while read line
        do
                domain=`echo $line |cut -d\" -f2 |cut -d" " -f1 |grep -v _ |grep -v "@"`
                if [ ! -z "$domain" ]; then
                        # If Whitelist exists and domain in WL skip domain
                        if [ -f "$whitelistFile" ]; then
                            inWL=`grep $domain $whitelistFile`
                            if [ ! -z "$inWL" ]; then
                                echo "### Skipping Domain from $whitelistFile ($domain)"
                                continue
                            fi
                        fi
                        echo "zone \"${domain}\"  { type master; notify no; file \"${destZoneFilename}\"; };" >> $destZoneConfigInChroot
                fi
        done < $blockFile
done

# Restart named
if [ "$restartNamed" == "Y" ]; then
    echo "# Restarting named"
    service named.sh restart
fi

echo "# Finished"
