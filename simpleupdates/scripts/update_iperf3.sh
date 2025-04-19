#!/bin/bash

# Define constants
# Define GitHub repo info
GITUSER="iamromulan"
REPONAME="quectel-rgmii-toolkit"
GITTREE="SDXLEMUR"
GITMAINTREE="SDXLEMUR"
GITDEVTREE="development-SDXLEMUR"
GITROOT="https://raw.githubusercontent.com/$GITUSER/$REPONAME/$GITTREE"
GITROOTMAIN="https://raw.githubusercontent.com/$GITUSER/$REPONAME/$GITMAINTREE"
GITROOTDEV="https://raw.githubusercontent.com/$GITUSER/$REPONAME/$GITDEVTREE"
MYGITROOT="https://110.42.96.64:21891/jjx/quectel-rgmii-toolkit/raw/branch/Development"

# Define filesystem path
DIR_NAME="simpleupdates"
SERVICE_FILE="/lib/systemd/system/install_iperf3.service"
SERVICE_NAME="install_iperf3"
TMP_SCRIPT="/tmp/install_iperf3.sh"
LOG_FILE="/tmp/install_iperf3.log"

# Tmp Script dependent constants 


# Create the systemd service file
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Update $DIR_NAME temporary service

[Service]
Type=oneshot
ExecStart=/bin/bash $TMP_SCRIPT > $LOG_FILE 2>&1

[Install]
WantedBy=multi-user.target
EOF

# Create and populate the temporary shell script for installation
cat <<EOF > "$TMP_SCRIPT"
#!/bin/bash

# Define GitHub repo info
GITUSER="iamromulan"
REPONAME="quectel-rgmii-toolkit"
GITTREE="SDXLEMUR"
GITMAINTREE="SDXLEMUR"
GITDEVTREE="development-SDXLEMUR"
GITROOT="https://raw.githubusercontent.com/$GITUSER/$REPONAME/$GITTREE"
GITROOTMAIN="https://raw.githubusercontent.com/$GITUSER/$REPONAME/$GITMAINTREE"
GITROOTDEV="https://raw.githubusercontent.com/$GITUSER/$REPONAME/$GITDEVTREE"
MYGITROOT="https://110.42.96.64:21891/jjx/quectel-rgmii-toolkit/raw/branch/Development"


install_iperf3() {
    echo -e "\e[1;32miperf3 Server\e[0m"
    remount_rw

    mkdir /usrdata/iperf3
    wget --no-check-certificate -O /lib/systemd/system/iperf3.service "$MYGITROOT/iperf3/iperf3.service"
    ln -sf "/lib/systemd/system/iperf3.service" "/lib/systemd/system/multi-user.target.wants/"

    opkg install iperf3
    for script in /opt/etc/init.d/*iperf3*; do
    if [ -f "$script" ]; then
        echo "Removing existing iperf3 init script: $script"
        rm "$script" # Remove the script if it contains 'iperf3' in its name
    fi
    done
    systemctl daemon-reload
    systemctl enable iperf3
    systemctl start iperf3

    echo -e "\e[1;32miperf3 installed!!\e[0m"
}
install_iperf3
exit 0
EOF

# Make the temporary script executable
chmod +x "$TMP_SCRIPT"

# Reload systemd to recognize the new service and start the update
systemctl daemon-reload
systemctl start $SERVICE_NAME
