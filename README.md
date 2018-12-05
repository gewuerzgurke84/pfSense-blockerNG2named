# pfSense-blockerNG2named
Small script to convert pfBlockerNG DNS Blacklists to named configuration
# Purpose
pfSense users which like the pfBlockerNG addon and the bind9 as a recursive DNS server can benefit from pfBlockerNG DNS blocking functionalities even with installed bind9.
This script can be installed on a pfSense machine and converts given DNS blocklist in a bind compatible way. 
It was tested with: pfSense 2.4.3/2.4.4/2.4.4_1, pfBlockerNG 2.1.2_3/pfBlockerNG-Devel 2.2.5_19 and bind9.12
# Prerequisite

   * You need to have pfBlockerNG / pfBlockerNG-Devel installed and configured. Consider following guides: https://www.tecmint.com/install-configure-pfblockerng-dns-black-listing-in-pfsense/
https://www.linuxincluded.com/block-ads-malvertising-on-pfsense-using-pfblockerng-dnsbl/

   * You need to have bind installed and serving your clients dns requests
   
   * For compatibility reasons you need to ensure unbound is running. I've activated it on port 53535 running on localhost only so it does not interfere with bind or something lese
   
   * pfBlocker services must be activated
   
   * SSH Login Rights
# Installation
## Login via ssh
## Copy script
```
$ cd /root/ && curl https://raw.githubusercontent.com/gewuerzgurke84/pfSense-blockerNG2named/master/createBlockingRPZone.sh > createBlockingRPZone.sh
$ chmod +x createBlockingZonefile.sh
```
## Adjust parameters for your environment
- [x] Please adjust the $destVIP parameter to the configured DNSBL Virtual IP (can be found unter Firewall > pfBlockerNG > DNSBL).
- [x] Decide if the script should restart named automatically $restartNamed (Y/N)
- [x] Add whitelist entries for domains if necessary (see $whitelistFile)
## Add global options to allow response-policy zones
Navigate to Services > BIND DNS Server > Settings
Click on "Show Advanced Settings" on the bottom of the page
Add following statement to "Custom Options"
```
response-policy { zone "blackhole"; };
```
## Add created zone file to bind zone
Navigate to Services > BIND DNS Server > View.
Select the zone that should block DNS requests based on pfBlockerNG data.
Add include statement
```
zone "blackhole" {
  type master;
  file "/etc/namedb/fuck.ads.zone";
};
```
## Activate it!
Now it's time to let the script run the first time:
```
[2.4.4-RELEASE][admin@limes.alex.hunters.lan]/root: ./createBlockingRPZone.sh
# Creating zone file (/cf/named/etc/namedb/fuck.ads.zone)
# Collecting configured pfBlockerNG DNS Blacklist Files (/var/db/pfblockerng/dnsbl/*.txt)
## Processing /var/db/pfblockerng/dnsbl/Abuse_DOMBL.txt
## Processing /var/db/pfblockerng/dnsbl/Abuse_URLBL.txt
## Processing /var/db/pfblockerng/dnsbl/Abuse_Zeus_BD.txt
## Processing /var/db/pfblockerng/dnsbl/Abuse_urlhaus.txt
## Processing /var/db/pfblockerng/dnsbl/Adaway.txt
## Processing /var/db/pfblockerng/dnsbl/BBC_DC2.txt
## Processing /var/db/pfblockerng/dnsbl/Cameleon.txt
## Processing /var/db/pfblockerng/dnsbl/D_Me_ADs.txt
## Processing /var/db/pfblockerng/dnsbl/D_Me_Malv.txt
## Processing /var/db/pfblockerng/dnsbl/D_Me_Malw.txt
## Processing /var/db/pfblockerng/dnsbl/D_Me_Tracking.txt
## Processing /var/db/pfblockerng/dnsbl/EasyList.txt
## Processing /var/db/pfblockerng/dnsbl/EasyList_German.txt
## Processing /var/db/pfblockerng/dnsbl/EasyPrivacy.txt
## Processing /var/db/pfblockerng/dnsbl/ISC_SDH.txt
## Processing /var/db/pfblockerng/dnsbl/MDL.txt
## Processing /var/db/pfblockerng/dnsbl/MDS.txt
## Processing /var/db/pfblockerng/dnsbl/MDS_Immortal.txt
## Processing /var/db/pfblockerng/dnsbl/MVPS.txt
## Processing /var/db/pfblockerng/dnsbl/SBL_ADs.txt
## Processing /var/db/pfblockerng/dnsbl/SFS_Toxic_BD.txt
## Processing /var/db/pfblockerng/dnsbl/SWC.txt
## Processing /var/db/pfblockerng/dnsbl/Spam404.txt
## Processing /var/db/pfblockerng/dnsbl/Yoyo.txt
## Processing /var/db/pfblockerng/dnsbl/hpHosts_ATS.txt
# Apply whitelist (/root/createBlockingRPZoneWhitelist.txt)
# Build RP Zone File
# Restarting named
# Finished
```
Optionally:
Let this script run on a regular basis using built-in cron. (Services > Cron)

I've followed this guide to implement the blacklisting via bind's response-policy feature:
http://www.zytrax.com/books/dns/ch9/rpz.html


