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
SERVICE_FILE="/lib/systemd/system/install_rtty.service"
SERVICE_NAME="install_rtty"
TMP_SCRIPT="/tmp/install_rtty.sh"
LOG_FILE="/tmp/install_rtty.log"

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


install_rtty() {
    echo -e "\e[1;32mrtty Util\e[0m"
    remount_rw

    opkg install ldd
    opkg install libev

    echo "Installing rtty..."
        echo "Downloading binary files..."
        cd /tmp/
        curl -k -L -O $MYGITROOT/rtty-nossl_8.1.3_armv7.tgz
        tar -xzf rtty-nossl_8.1.3_armv7.tgz -C /
     rm rtty-nossl_8.1.3_armv7.tgz
        cd /opt/sbin/
        ln -sf rtty-nossl rtty
        chmod +x rtty
        chmod +x rtty-*
        cd /

    mkdir /usrdata/rtty
    wget --no-check-certificate -O /lib/systemd/system/rtty.service "$MYGITROOT/rtty/rtty.service"
    ln -sf "/lib/systemd/system/rtty.service" "/lib/systemd/system/multi-user.target.wants/"

    for script in /opt/etc/init.d/*rtty*; do
    if [ -f "$script" ]; then
        echo "Removing existing rtty init script: $script"
        rm "$script" # Remove the script if it contains 'rtty' in its name
    fi
    done
    systemctl daemon-reload
    systemctl enable rtty
    systemctl start rtty

    echo -e "\e[1;32mrtty installed!!\e[0m"
}
install_rtty
exit 0
EOF

# Make the temporary script executable
chmod +x "$TMP_SCRIPT"

# Reload systemd to recognize the new service and start the update
systemctl daemon-reload
systemctl start $SERVICE_NAME
