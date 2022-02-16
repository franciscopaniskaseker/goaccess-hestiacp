#!/bin/bash

# functions
source library.sh

main()
{
	# note: exclude old file
	echo "#!/bin/bash" > $goaccess_hestiacp_command
	cat $library_file >> $goaccess_hestiacp_command
	cat $main_file >> $goaccess_hestiacp_command
	chmod o+x,g+x $goaccess_hestiacp_command
	cat <<EOF> /etc/goaccess-hestiacp.conf
report_user=$report_user
report_group=$report_group
public_report_file=$public_report_file
EOF

	installSystemdUnit
	exit 0
}

# vars
main_file=main.sh
library_file=library.sh
goaccess_hestiacp_command=/usr/bin/goaccess-hestiacp
report_user=$1
report_group=$2
public_report_file=$3

# main
main

# unknown error
exit 255
