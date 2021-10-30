clear
DATE_START=$(date "+%Y-%m-%d %H:%M:%S")
git config --global http.sslVerify false
export GIT_SSL_NO_VERIFY=1

echo "$DATE_START"
cd ~ || exit
rm -rf NanoPi-R2S-2021
REPO_URL="https://github.com/coolsnowwolf/lede"
REPO_BRANCH="master"
CONFIG_FILE="configs/lean/lean_stable.config"
DIY_SH="scripts/lean.sh"
KMODS_IN_FIRMWARE="false"

echo "Clone Source Code"
git clone https://github.com/quzard/NanoPi-R2S-2021.git
cd NanoPi-R2S-2021
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


echo "Install Feeds"
cd $OPENWRTROOT
./scripts/feeds install -a

echo "Load Custom Configuration"
cd $FIRMWARE
[ -e files ] && mv files $OPENWRTROOT/files
[ -e $CONFIG_FILE ] && mv $CONFIG_FILE $OPENWRTROOT/.config
cd $OPENWRTROOT
../$DIY_SH
../scripts/preset-clash-core.sh armv8
../scripts/preset-terminal-tools.sh
make defconfig

echo "Download Package"
cd $OPENWRTROOT
../scripts/modify_config.sh
mkdir dl
cd dl
wget http://miniupnp.free.fr/files/miniupnpd-2.0.20170421.tar.gz
cd ..
make download -j$(nproc)
make download -j1 V=s

chmod -R 777 ./

echo "Generate Firmware"
cd $FIRMWARE/configs/opkg
sed -i "s/subtarget/armv8/g" distfeeds*.conf
sed -i "s/target\//rockchip\//g" distfeeds*.conf
sed -i "s/platform/aarch64_generic/g" distfeeds*.conf
cd $OPENWRTROOT
mkdir -p files/etc/uci-defaults/
cp ../scripts/init-settings.sh files/etc/uci-defaults/99-init-settings
mkdir -p files/etc/opkg
cp ../configs/opkg/distfeeds-packages-server.conf files/etc/opkg/distfeeds.conf.server
mkdir -p files/etc/opkg/keys
cp ../configs/opkg/1035ac73cc4e59e3 files/etc/opkg/keys/1035ac73cc4e59e3
cp ../configs/opkg/distfeeds-18.06-remote.conf files/etc/opkg/distfeeds.conf
cp files/etc/opkg/distfeeds.conf.server files/etc/opkg/distfeeds.conf.mirror
sed -i "s/http:\/\/192.168.123.100:2345\/snapshots/https:\/\/openwrt.cc\/snapshots\/$(date +"%Y-%m-%d")\/lean/g" files/etc/opkg/distfeeds.conf.mirror

make  -j$(nproc) || make  -j$(nproc) || make  -j1 V=s




cp $OPENWRTROOT/bin/targets/rockchip/armv8/openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs-sysupgrade.img.gz /home/user/openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs-sysupgrade.img.gz
cd /home/user
DATE_END=$(date "+%Y-%m-%d %H:%M:%S")
echo "DATE_START:$DATE_START"
echo "DATE_END:$DATE_END"

