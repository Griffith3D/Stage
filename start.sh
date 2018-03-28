#!/bin/bash

echo "net.ipv4.ip_local_port_range = 8888 65000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

echo "192.168.33.1    avocatbox.dev" | tee -a /etc/hosts

echo "Running the run_supervisor function."
supervisord -c /etc/supervisord.conf
supervisorctl -c /etc/supervisord.conf
supervisorctl reread
supervisorctl update
supervisord -n
