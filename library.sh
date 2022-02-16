installSystemdUnit()
{
	cat <<EOF> /etc/systemd/system/goaccess-hestiacp.service
[Unit]
Description=Goaccess Web log report.
After=network.target

[Service]
Type=simple
User=root
Group=root
Restart=always
RuntimeMaxSec=300
ExecStart=$goaccess_hestiacp_command
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOF
	systemctl daemon-reload
	systemctl enable --now goaccess-hestiacp
}


getActiveUsersHestiacp()
{
  # avoid to use v-list-users due possible environment variables changes
  # using the same method used by v-list-users
  hestiacp_possible_accounts=$(cat /etc/passwd | egrep @ | cut -f1 -d:)
  for hestia_user in $hestiacp_possible_accounts
  do
    if [ -f "/usr/local/hestia/data/users/$hestia_user/user.conf" ]
    then
      if cat /usr/local/hestia/data/users/$hestia_user/user.conf | egrep -qi "^suspended.*\=.*no.*"
      then
            echo $hestia_user >> $temp_hestiacp_accounts
      fi
    fi
  done
}

getAllAccessLogFiles()
{
	while read -r hestiacp_account;
	do
        # get all possible access log files
        site_log_files=$(find /home/${hestiacp_account}/web/*/logs/ -maxdepth 1 -iname "*.log" | egrep -iv error)

        for site_log_file in $site_log_files
        do
			# double check if the log file exist
            if [ -f $site_log_file ]
            then
                echo $site_log_file >> $temp_site_logs_file_list
            fi
        done
    done < $temp_hestiacp_accounts
}

createGoaccesssConfFile()
{
	cat <<EOF> $goaccess_conf_file
time-format %H:%M:%S
date-format %d/%b/%Y
log-format %h %^[%d:%t %^] "%r" %s %b "%R" "%u"
config-dialog false
hl-header true
json-pretty-print false
no-color false
no-column-names false
no-csv-summary false
no-progress false
no-tab-scroll false
with-mouse false
agent-list false
with-output-resolver false
http-method yes
http-protocol yes
no-query-string false
no-term-resolver false
444-as-404 false
4xx-to-unique-count false
all-static-files false
double-decode false
ignore-crawlers false
crawlers-only false
ignore-panel REFERRERS
ignore-panel KEYPHRASES
real-os true
static-file .css
static-file .js
static-file .jpg
static-file .png
static-file .gif
static-file .ico
static-file .jpeg
static-file .pdf
static-file .csv
static-file .mpeg
static-file .mpg
static-file .swf
static-file .woff
static-file .woff2
static-file .xls
static-file .xlsx
static-file .doc
static-file .docx
static-file .ppt
static-file .pptx
static-file .txt
static-file .zip
static-file .ogg
static-file .mp3
static-file .mp4
static-file .exe
static-file .iso
static-file .gz
static-file .rar
static-file .svg
static-file .bmp
static-file .tar
static-file .tgz
static-file .tiff
static-file .tif
static-file .ttf
static-file .flv
static-file .dmg
static-file .xz
static-file .zst
EOF

	local_log_file=""
	while read -r local_log_file;
	do
		echo "log-file ${local_log_file}"  >> $goaccess_conf_file
    done < $temp_site_logs_file_list
}

executeGoaccess()
{
	i=0
	while [ $i -lt 60 ] 
	do
		goaccess -p /etc/goaccess/goaccess.conf -a > $public_report_file
		chown ${report_user}:${report_group} $public_report_file
		i=$(($i+1))
		sleep 60
	done
}

checkEtcConfig()
{
	if ! cat /etc/passwd | egrep -iq $report_user
	then
		echo "User >>> $report_user <<< does not exist. Please check the $etc_config file"
		exit 1
	fi

	if ! cat /etc/group | egrep -iq $report_group
	then
		echo "Group >>> $report_group <<< does not exist. Please check the $etc_config file"
		exit 2
	fi

	get_basename=$(dirname $public_report_file)
	if [ ! -d $get_basename ]
	then
		# the public directory does not exist
		echo "The directory >>> $get_basename <<< does not exist. Please check the $etc_config file"
		exit 3
	fi
}
