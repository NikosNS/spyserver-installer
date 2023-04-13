#!/bin/bash

# simple function to wait few seconds
timeout () {
  for (( i=1; i<=7; i++ ))
  do
    printf "\033[0;31m.\n\033[0m"
    for j in $(seq 1 $i)
    do
      printf "\033[0;31m.\033[0m"
      sleep 1
    done
  done
}


# cheeck if user is root
if [ `whoami` != 'root' ]
then
  printf "\033[0;31mNeed root, try \033[0;32msudo -i\033[0m \033[0;31mbefore start\n\033[0m"
  exit 0
fi

# upgrade and install all libraries
apt update && apt upgrade -y && apt install -y rtl-sdr librtlsdr-dev librtlsdr0 wget htop tmux git iftop

# check if there is not first attempt to install
if [ -d /home/pi/spyserver ]
then
  echo "already installed"
  rm -rf /home/pi/spyserver*
fi
cd /home/pi && mkdir spyserver && cd spyserver

# download the spyservers archieve from oficial site, depends on architecture
if [ `uname -m` == 'aarch64' ]
then
  wget -O spyserver.tgz https://www.airspy.com/?ddownload=5795
else
  wget -O spyserver.tgz https://www.airspy.com/?ddownload=4247
fi
tar xvzf spyserver.tgz && rm *.tgz

# editing configfile, then moving files to /usr/bin and /etc
printf "You can add some new parameters in configfile via Nano editor after few sec\n"
timeout
nano spyserver.config
cp spyserver /usr/bin && cp spyserver.config /etc
chown -R pi:pi /home/pi/spyserver

# creating the service file, then creating aliases,
# and crontab dependencies based by ping,
# also I download rtl-sdr.rules with right
# permissions to all users in all groups
cat <<EOF > /etc/systemd/system/spyserver.service
[Unit]
Description=spyserver always running service
After=network.target
StartLimitBurst=5
StartLimitIntervalSec=10

[Service]
Type=simple
Restart=always
RestartSec=5
User=pi
ExecStart=/usr/bin/spyserver /etc/spyserver.config

[Install]
WantedBy=multi-user.target
EOF
cat <<EOF >>/home/pi/.bashrc
alias sstart='sudo systemctl start spyserver.service'
alias sstop='sudo systemctl stop spyserver.service'
EOF
wget https://raw.githubusercontent.com/keenerd/rtl-sdr/master/rtl-sdr.rules && mv rtl-sdr.rules /etc/udev/rules.d/
printf "Print 2 IP to bind service activity by ping them \n"
read -p "Example 8.8.8.8 1.1.1.1:  " ip1 ip2
cat <<EOF >> /home/pi/spyserver/pingtest.sh
#!/bin/bash

ping -c 3 $ip1 >/dev/null || ping -c 3 $ip2 >/dev/null
v=\$?
s=\`systemctl is-active spyserver.service\`
if [ \$v -eq 0 ] && [ \$s == 'inactive' ]
then
  systemctl start spyserver.service
elif [ \$v -ne 0 ]
then
  systemctl stop spyserver.service
fi
EOF
chmod +x /home/pi/spyserver/pingtest.sh
echo "*/3 * * * * root /home/pi/spyserver/" >> /etc/crontab
systemctl enable spyserver.service && systemctl daemon-reload && systemctl start spyserver.service

# additional info and condition for reboot the system
printf "\n"
timeout
printf "\nTo stop or start service print \033[0;32msstart\033[0m or \033[0;32msstart\033[0m\nOr do it throught \033[0;32msystemctl\n\033[0m"
printf "System needs reboot, chose the option and press enter,\t y/N "
read yn
if [ $yn == 'y' ]
then
  printf "\033[0;31mreboot now\n\033[0m"
  timeout
  reboot now
else
  printf "Restart your system mannualy with \033[0;32msudo reboot\033[0m \n"
  exit 0
fi