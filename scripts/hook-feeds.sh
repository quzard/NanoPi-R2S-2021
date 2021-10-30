#!/bin/bash
rm -rf package/qca/

# Svn checkout packages from immortalwrt's repository
pushd customfeeds

# Add luci-app-eqos
svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-eqos luci/applications/luci-app-eqos

# Add luci-proto-modemmanager
svn co https://github.com/immortalwrt/luci/trunk/protocols/luci-proto-modemmanager luci/protocols/luci-proto-modemmanager

# Add luci-app-gowebdav
svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-gowebdav luci/applications/luci-app-gowebdav
svn co https://github.com/immortalwrt/packages/trunk/net/gowebdav packages/net/gowebdav

# Add luci-app-netdata
rm -rf packages/admin/netdata
svn co https://github.com/281677160/openwrt-package/trunk/feeds/packages/net/netdata packages/admin/netdata
rm -rf ../package/lean/luci-app-netdata
svn co https://github.com/281677160/openwrt-package/trunk/feeds/luci/applications/luci-app-netdata luci/applications/luci-app-netdata

# Add tmate
git clone --depth=1 https://github.com/immortalwrt/openwrt-tmate

# Add luci-app-passwall
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall luci/applications/openwrt-passwall
git clone -b hello https://github.com/DHDAXCW/openwrt-passwall luci/applications/openwrt-passwall

# Add gotop
svn co https://github.com/immortalwrt/packages/branches/openwrt-18.06/admin/gotop packages/admin/gotop

# Replace smartdns with the official version
rm -rf packages/net/smartdns
svn co https://github.com/openwrt/packages/trunk/net/smartdns packages/net/smartdns


git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter packages/net/subconverter
svn co https://github.com/immortalwrt/packages/trunk/libs/jpcre2 packages/libs/jpcre2
svn co https://github.com/immortalwrt/packages/trunk/libs/rapidjson packages/libs/rapidjson
svn co https://github.com/immortalwrt/packages/trunk/libs/libcron packages/libs/libcron
svn co https://github.com/immortalwrt/packages/trunk/libs/quickjspp packages/libs/quickjspp
svn co https://github.com/immortalwrt/packages/trunk/libs/toml11 packages/libs/toml11


popd

# Set to local feeds
pushd customfeeds/packages
export packages_feed="$(pwd)"
popd
pushd customfeeds/luci
export luci_feed="$(pwd)"
popd
sed -i '/src-git packages/d' feeds.conf.default
echo "src-link packages $packages_feed" >> feeds.conf.default
sed -i '/src-git luci/d' feeds.conf.default
echo "src-link luci $luci_feed" >> feeds.conf.default

# Update feeds
./scripts/feeds update -a

# FRP 内网穿透
rm -rf ./feeds/luci/applications/luci-app-frpc
rm -rf ./feeds/packages/net/frp
rm -f ./package/feeds/packages/frp
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-frpc package/lean/luci-app-frpc
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/frp package/lean/frp