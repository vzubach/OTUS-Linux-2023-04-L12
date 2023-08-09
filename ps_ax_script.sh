#!bin/bash

function psax() {
        PID=$(awk '/^Pid/ {print $2 }' $1/status | tr '\0' '\b')
        STAT=$(awk '/^State/ {print $2 }' $1/status | tr '\0' '\b')
        TIME=$(date -d@$(echo "$(($(awk '{print $14+$15}' $1/stat) / $(getconf CLK_TCK)))") +%M:%S)
        if [[ $(awk '{print length($0)}' $1/cmdline) -ge 0 ]]; then COMMAND=$(awk '{print substr($0,0,120)}' $1/cmdline | tr '\0' '\b'); else COMMAND=$(awk '{print "["$0"]"}' $1/comm); fi
        if sudo ls -l $1/fd/ | grep "/dev/tty" 1> /dev/null; then TTY=$(sudo ls -l $1/fd/ | grep "/dev/tty" | head -n1 | awk -F "/" '{print $3}'); 
        elif sudo ls -l $1/fd/ | grep "/dev/pts" 1> /dev/null; then TTY=$(sudo ls -l $1/fd/ | grep "/dev/pts" | head -n1 | awk -F "/" '{print $3"/"$4}'); else TTY="?"; fi
        echo -e "$PID\t$TTY\t$STAT\t$TIME\t$COMMAND"
}
export -f psax
echo -e "PID\tTTY\tSTAT\tTIME\tCOMMAND"
find /proc/ -maxdepth 1 -type d -name "[0-9]*" -exec bash -c "psax '{}'" \;

