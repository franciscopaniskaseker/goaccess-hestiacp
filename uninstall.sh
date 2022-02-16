#!/bin/bash

systemctl stop goaccess-hestiacp
systemctl disable goaccess-hestiacp
rm -f /etc/systemd/system/goaccess-hestiacp.service
rm -f /etc/goaccess-hestiacp.conf
rm -f /usr/bin/goaccess-hestiacp
systemctl daemon-reload
