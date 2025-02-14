#!/bin/bash

SUDO=$(if [ $(id -u $whoami) -gt 0 ]; then echo "sudo "; fi)

clean_services () {
    [[ -z $1 ]] && return 0
    find /etc/systemd/system/multi-user.target.wants -maxdepth 1 -type l -name $1 -exec $SUDO systemctl disable --now {} +
    find /etc/systemd/system/timers.target.wants -maxdepth 1 -type l -name $1 -exec $SUDO systemctl disable --now {} +
    find /etc/systemd/system -maxdepth 1 -type f -name $1 -exec $SUDO rm {} +
}

clean_iptables () {
    while [[ ! -z "$($SUDO iptables -S | grep -Ee 'DOWNLOAD(-UDP)? [0-9]+->' -Ee 'UPLOAD(-UDP)? [0-9]+->' -Ee 'FORWARD(-UDP)? [0-9]+->' -Ee 'BACKWARD(-UDP)? [0-9]+->')" ]]
    do
        $SUDO iptables -S | grep -Ee 'DOWNLOAD(-UDP)? [0-9]+->' -Ee 'UPLOAD(-UDP)? [0-9]+->' -Ee 'FORWARD(-UDP)? [0-9]+->' -Ee 'BACKWARD(-UDP)? [0-9]+->' | awk -v SUDO="$SUDO" '{$1="";$COMMEND=SUDO" iptables -D "$0; system($COMMEND)}'
    done
    while [[ ! -z "$($SUDO iptables -t nat -S | grep -Ee 'DOWNLOAD(-UDP)? [0-9]+->' -Ee 'UPLOAD(-UDP)? [0-9]+->' -Ee 'FORWARD(-UDP)? [0-9]+->' -Ee 'BACKWARD(-UDP)? [0-9]+->')" ]]
    do
        $SUDO iptables -t nat -S | grep -Ee 'DOWNLOAD(-UDP)? [0-9]+->' -Ee 'UPLOAD(-UDP)? [0-9]+->' -Ee 'FORWARD(-UDP)? [0-9]+->' -Ee 'BACKWARD(-UDP)? [0-9]+->' | awk -v SUDO="$SUDO" '{$1="";$COMMEND=SUDO" iptables -t nat -D "$0; system($COMMEND)}'
    done
    clean_services "iptables-restore.service"
    clean_services "ip6tables-restore.service"
    clean_services "iptables-check.service"
    clean_services "iptables-check.timer"
}

clean_aurora () {
    $SUDO systemctl stop system-aurora.slice
    clean_services "aurora@*.service"
    $SUDO rm -rf /usr/local/etc/aurora
}

clean_scripts () {
    $SUDO rm /usr/local/bin/iptables.sh
    $SUDO rm /usr/local/bin/tc.sh
    # compatible with 0.19.11- version
    $SUDO rm /usr/local/bin/app.sh
    $SUDO rm /usr/local/bin/get_traffic.sh
}

clean_iptables
clean_aurora
clean_scripts
