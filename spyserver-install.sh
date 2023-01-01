#!/bin/bash 

# by NikosNS
cd ~ 
apt update && apt upgrade -y && apt install -y airspy libairspy0 libairspy-dev rtl-sdr librtlsdr-dev 
apt install -y wget htop tmux iftop 
 
# check if  there is spyserver directory from previous installaltion 
while [ -d ~/spyserver ]; do 
  rm -rf ~/spyserver 
done 

mkdir spyserver && cd spyserver 
# there programm will have tryed to find app do with the architecture 
if [ `uname -m` == "armhf" ] || [ `uname -m` == "armv7l" ]; then 
  link="https://www.airspy.com/?ddownload=4247" 
elif [ `uname -m` == "aarch" ]; then 
  link="https://www.airspy.com/?ddownload=5795" 
elif [ `uname -m` == "x86_64" ]; then 
  link="https://www.airspy.com/?ddownload=4262" 
elif [ `uname -m` == "x86" ]; then 
  link="https://www.airspy.com/?ddownload=4308" 
else 
  echo "There is an unknown architecture" 
fi 
  
wget -O spyserver.tgz $link 
tar xvzf spyserver.tgz && rm -rf spyserver.tgz 
# there programm wants to know some specific parameters  
echo "Print the IP address for listening (default is 0.0.0.0), for example 192.168.1.0/24 or 8.8.8.8\n" 
read ip 
echo "Print the port (default is between 5555 and 6666)\n" 
read port 
echo "Print the type of device (for example RTL-SDR)\n" 
read device 
sed -e 's/bind_host = 0.0.0.0/bind_host = $ip/g' -e '/bind_port = 5555-6666/bind_port = $port/g' -e '/device_type = auto/device_type = $device/g' > spyserver.config 
 
