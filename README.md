# pfSense-blockerNG2named
Small script to convert pfBlockerNG DNS Blacklists to named configuration
# Purpose
pfSense users which like the pfBlockerNG addon and the bind9 as a recursive DNS server can benefit from pfBlockerNG DNS blocking functionalities even with installed bind9.
This script can be installed on a pfSense machine and converts given DNS blocklist in a bind compatible way. 
It was tested with pfSense 2.4.3, pfBlockerNG 2.1.2_3 and bind9.12
# Installation
I assume that you have pfBlockerNG installed and added some DNS Blocklists. I've succesfully done that with this guide (https://www.tecmint.com/install-configure-pfblockerng-dns-black-listing-in-pfsense/).
Furthermore there needs to be a bind running and you need access via ssh to your pfSense box.
Also ensure that unbound is running because pfBlockerNG relies on it. I've adjusted unbound dns port to 5353 and bound it to Localhost-only.
## Login via ssh
## Copy script
```
$ cd /root/ && curl https://raw.githubusercontent.com/gewuerzgurke84/pfSense-blockerNG2named/master/createBlockingZonefile.sh > createBlockingZonefile.sh
$ chmod +x createBlockingZonefile.sh
```
## Adjust parameters for your environment
- [x] Please adjust the $destVIP parameter to the configured DNSBL Virtual IP (can be found unter Firewall > pfBlockerNG > DNSBL).
- [x] Decide if the script should restart named automatically $restartNamed (Y/N)
- [x] Add whitelist entries for domains if necessary (see $whitelistFile)
## Add created zone file to bind zone
Navigate to Services > BIND DNS Server > View.
Select the zone that should block DNS requests based on pfBlockerNG data.
Add include statement
```
include "/etc/namedb/fuck.ads.conf";
```
## Add cron
Let this script run on a regular basis using built-in cron. (Services > Cron)


