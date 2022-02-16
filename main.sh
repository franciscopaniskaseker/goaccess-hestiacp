main()
{
	checkEtcConfig
	getActiveUsersHestiacp
	getAllAccessLogFiles
	createGoaccesssConfFile
	rm -f $temp_hestiacp_accounts $temp_site_logs_file_list
	executeGoaccess
	exit 0
}

# vars
temp_hestiacp_accounts=$(mktemp /tmp/XXXXXXXXXXXX)
temp_site_logs_file_list=$(mktemp /tmp/XXXXXXXXXXX)
goaccess_conf_file="/etc/goaccess/goaccess.conf"
etc_config="/etc/goaccess-hestiacp.conf"

source $etc_config

# main
main

# unknown error
exit 255
