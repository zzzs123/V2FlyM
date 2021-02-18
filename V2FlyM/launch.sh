#!/bin/sh

#  launch.sh
#  V2FlyM
#
#  Created by silly b on 2021/2/17.
#  
#echo `dirname "${BASH_SOURCE[0]}"`
#ls
#pwd

dir="$HOME/Library/Application Support/V2FlyM"
if [ ! -d "$dir" ];then
sudo mkdir -p "$dir"
echo "make dir V2FlyM success"
else
echo "V2FlyM exists"
fi

cd `dirname "${BASH_SOURCE[0]}"`
#sudo \cp -v com.v2flym.v2ray-core.plist "/Users/sillyb/Library/Application Support/V2FlyM/"
sudo \cp -rfv v2ray-core "$dir"
sudo \cp -fv config.json "$dir"

sudo chmod -R 755 "$dir"
