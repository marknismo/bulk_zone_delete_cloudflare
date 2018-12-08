#!/usr/bin/env bash

# Created by Mark C.
# Purpose of this script:
# - bulk delete zones in a file using CF API


# Global variables
zonefile=""
auth_email=""
auth_key=""
zonetag_array=()
zone_array=()
status_array=()
plan_array=()


read_file(){
	while IFS=$'\n' read -r line_data; do
		line_data=$(echo $line_data | awk '{$1=$1};1')
		zone_array+=( "${line_data}" )
	done < $zonefile
}



query_zonename(){
	# display the information a single zone
	# store zone tag in global zonetag_array
	local zonename=$1

	result=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones?name=$zonename&status=active&page=1&per_page=20&order=status&direction=desc&match=all" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json")

	echo $result
}



print_single_zone(){
	local zonename=$1
	local result=$2
	local zonetag=""
	local status=""
	local owner=""
	local plan=""

	zonetag=$(echo $result | jq -r '. | .result[] | .id')
	status=$(echo $result | jq -r '. | .result[] | .status')
	plan=$(echo $result | jq -r '. | .result[] | .plan.name')
	owner=$(echo $result | jq -r '. | .result[] | .account.name')

	zonetag_array+=("$zonetag")
	status_array+=("$status")
	plan_array+=("$plan")

	printf "%-60s" ${zonename} 
	echo -e "${status} \t ${plan} \t ${owner}"
}


print_all_zones(){
	#Display information for all the zones in the zone array

	local query_result=""
	local zonename=""

	echo -e "\nThe zones below will be deleted\n"

	for i in ${!zone_array[@]}; do
		zonename=${zone_array[$i]}
		query_result=$(query_zonename $zonename)
	  	print_single_zone "$zonename" "$query_result" 
	done	

}




delete_zone(){
	# delete a zone
	local zonetag=$1
	local zonename=$2
	local result=""
	local result_success=""

	result=$(curl -sX DELETE "https://api.cloudflare.com/client/v4/zones/${zonetag}" -H "X-Auth-Email: ${auth_email}" -H "X-Auth-Key: ${auth_key}" -H "Content-Type: application/json")

	result_success=$(echo $result | jq '. | .success')

	printf "%-60s" ${zonename} 
	echo -e "\t success: ${result_success}" 
}



delete_all_zones(){
	#delete all zones in zonetag array

	local zonename=""
	local zonetag=""

	echo -e "Deleting zones... \n"

	for i in ${!zonetag_array[@]}; do
		zonetag=${zonetag_array[$i]}
		zonename=${zone_array[$i]}
		delete_zone "${zonetag}" "${zonename}"

	done	
}


get_user_input(){

	echo -e "\nThis script will bulk delete zones in a file\n"
	echo -e "*************************************************\n"
	read -p 'Enter your email account to login to Cloudflare: ' auth_email
	read -sp 'Enter your Cloudflare API key : ' auth_key
	echo ""
	read -p 'Enter the filename containing the zones to delete in this directory (Enter blank to use zones.txt): ' zonefile
	zonefile="${zonefile:="zones.txt"}"

}


prompt_user(){
	echo -e "\nDo you wish to proceed to delete the above zones?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) return 0; break;;
	        No ) exit;;
	    esac
	done
}


get_user_input
read_file
print_all_zones
prompt_user
delete_all_zones




