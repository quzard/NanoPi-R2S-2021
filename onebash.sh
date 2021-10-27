DATE_START=$(date "+%Y-%m-%d %H:%M:%S")
git config --global http.sslVerify false
export GIT_SSL_NO_VERIFY=1
echo "$DATE_START"
cd ~ || exit
rm -rf NanoPi-R2S-2021
git config --global user.email "1191890118@qq.com"
git config --global user.name "quzard"
REPO_URL="https://github.com/coolsnowwolf/lede"
REPO_BRANCH="master"
CONFIG_FILE="configs/lean/lean.config"
DIY_SH="scripts/lean.sh"
KMODS_IN_FIRMWARE="true"

echo "Clone Source Code"
git clone https://github.com/quzard/NanoPi-R2S-2021.git
cd NanoPi-R2S-2021
SUBTARGET=$(basename `pwd`)
FIRMWARE=$PWD
export GITHUB_WORKSPACE=$PWD
git clone $REPO_URL -b $REPO_BRANCH openwrt

echo "Update Feeds"
cd openwrt
OPENWRTROOT=$PWD
mkdir customfeeds
git clone --depth=1 https://github.com/coolsnowwolf/packages customfeeds/packages
git clone --depth=1 https://github.com/coolsnowwolf/luci customfeeds/luci
chmod +x ../scripts/*.sh
../scripts/hook-feeds.sh

echo "MOD index file"
cd $OPENWRTROOT/package/lean/autocore/files/arm
sed -i '/Load Average/i\\t\t<tr><td width="33%"><%:Telegram %></td><td><a href="https://t.me/DHDAXCW"><%:电报交流群%></a></td></tr>' index.htm

echo "Install Feeds"
cd $OPENWRTROOT
./scripts/feeds install -a

echo "Load Custom Configuration"
cd $FIRMWARE
[ -e files ] && mv files $OPENWRTROOT/files
[ -e $CONFIG_FILE ] && mv $CONFIG_FILE $OPENWRTROOT/.config
chmod +x scripts/*.sh
cd $OPENWRTROOT
../$DIY_SH
../scripts/preset-clash-core.sh armv8
../scripts/preset-terminal-tools.sh
make defconfig

echo "Download Package"
cd $OPENWRTROOT
if "$KMODS_IN_FIRMWARE" = 'true'
then
    echo "CONFIG_ALL_NONSHARED=y" >> .config
fi
../scripts/modify_config.sh
make download -j $(nproc) | make download -j1
chmod -R 777 ./

echo "Compile Packages"
echo "$(nproc) thread compile"
cd $OPENWRTROOT
make tools/compile -j$(nproc) || make tools/compile -j1 V=s
make toolchain/compile -j$(nproc) || make toolchain/compile -j1 V=s
make target/compile -j$(nproc) || make target/compile -j1 V=s IGNORE_ERRORS=1
make diffconfig
make package/compile -j$(nproc) IGNORE_ERRORS=1 || make package/compile -j1 V=s IGNORE_ERRORS=1
make package/index
cd $OPENWRTROOT/bin/packages/*
PLATFORM=$(basename `pwd`)
cd $OPENWRTROOT/bin/targets/*
TARGET=$(basename `pwd`)

echo "Generate Firmware"
cd $SUBTARGET/configs/opkg
sed -i "s/subtarget/$SUBTARGET/g" distfeeds*.conf
sed -i "s/target\//$TARGET\//g" distfeeds*.conf
sed -i "s/platform/$PLATFORM/g" distfeeds*.conf
cd $OPENWRTROOT
mkdir -p files/etc/uci-defaults/
cp ../scripts/init-settings.sh files/etc/uci-defaults/99-init-settings
mkdir -p files/etc/opkg
cp ../configs/opkg/distfeeds-packages-server.conf files/etc/opkg/distfeeds.conf.server
mkdir -p files/etc/opkg/keys
cp ../configs/opkg/1035ac73cc4e59e3 files/etc/opkg/keys/1035ac73cc4e59e3
if "$KMODS_IN_FIRMWARE" = 'true'
then
    mkdir -p files/www/snapshots
    cp -r bin/targets files/www/snapshots
    cp ../configs/opkg/distfeeds-18.06-local.conf files/etc/opkg/distfeeds.conf
else
    cp ../configs/opkg/distfeeds-18.06-remote.conf files/etc/opkg/distfeeds.conf
fi
cp files/etc/opkg/distfeeds.conf.server files/etc/opkg/distfeeds.conf.mirror
sed -i "s/http:\/\/192.168.123.100:2345\/snapshots/https:\/\/openwrt.cc\/snapshots\/$(date +"%Y-%m-%d")\/lean/g" files/etc/opkg/distfeeds.conf.mirror

make package/install -j$(nproc) || make package/install -j1 V=s
make target/install -j$(nproc) || make target/install -j1 V=s




cp $OPENWRTROOTbin/targets/rockchip/armv8/openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs-sysupgrade.img.gz /home/user/openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs-sysupgrade.img.gz
cd /home/user
DATE_END=$(date "+%Y-%m-%d %H:%M:%S")
echo "DATE_START:$DATE_START"
echo "DATE_END:$DATE_END"

