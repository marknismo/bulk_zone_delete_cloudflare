# Bulk zone delete using Cloudflare API
Helper script to bulk delete zones on CF

# Purpose of Bulk delete zone helper
- script the bulk removal of zones


# Features
- display the zone status, zone plan, owner before removal
- prompt user for confirmation before deletion
- show status of zone after delete


# Usage
- place zones to be deleted in a text file
- chmod u+x bulk_delete.sh
- run "./bulk_delete.sh"


# Pre-requsite
- install jq


Screenshot of what it looks like on Mac OS
![screenshot](https://raw.githubusercontent.com/marknismo/bulk_zone_delete_cloudflare/master/zones.jpg)
![screenshot](https://raw.githubusercontent.com/marknismo/bulk_zone_delete_cloudflare/master/bulk_delete.jpg)
