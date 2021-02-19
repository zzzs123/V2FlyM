#!/bin/sh

#  install.sh
#  V2FlyM
#
#  Created by silly b on 2021/2/17.
#  

dir="$HOME/Library/Application Support/V2FlyM"
echo "$dir/proxy_conf"

if [ ! -d "$dir" ];then
sudo mkdir -p "$dir"
echo "mkdir V2FlyM"
else
echo "V2FlyM exists"
fi

cd `dirname "${BASH_SOURCE[0]}"`
sudo \cp -fv proxy_conf "$dir"
sudo \cp -rfv v2ray-core "$dir"

sudo chown root:admin "$dir/proxy_conf"
sudo chmod a+rx "$dir/proxy_conf"
sudo chmod +s "$dir/proxy_conf"

echo "$dir/proxy_conf"

#sudo chmod -R 755 "$dir"
