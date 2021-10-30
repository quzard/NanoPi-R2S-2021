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


# FRP 内网穿透
rm -rf ./feeds/luci/applications/luci-app-frpc
rm -rf ./feeds/packages/net/frp
rm -f ./package/feeds/packages/frp
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-frpc package/lean/luci-app-frpc
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/frp package/lean/frp

# luci-app-seu-net
git clone https://github.com/quzard/luci-app-seu-net.git package/lean/luci-app-seu-net

# sub-web
rm -rf $(find . -name "*sub-web*")
git clone https://github.com/quzard/openwrt-sub-web.git package/openwrt-sub-web

# vlmcsd
rm -rf $(find . -name "*vlmcsd*")

# zerotier
rm -rf $(find . -name "*zerotier*")

# 订阅转换
svn co https://github.com/immortalwrt/packages/trunk/net/subconverter feeds/packages/net/subconverter
sed -i '\/bin\/subconverter/a\\t$(STAGING_DIR_HOST)/bin/upx --lzma --best $(1)/usr/bin/subconverter' feeds/packages/net/subconverter/Makefile
ln -sf ../../../feeds/packages/net/subconverter ./package/feeds/packages/subconverter
svn co https://github.com/immortalwrt/packages/trunk/libs/jpcre2 feeds/packages/libs/jpcre2
ln -sf ../../../feeds/packages/libs/jpcre2 ./package/feeds/packages/jpcre2
svn co https://github.com/immortalwrt/packages/trunk/libs/rapidjson feeds/packages/libs/rapidjson
ln -sf ../../../feeds/packages/libs/rapidjson ./package/feeds/packages/rapidjson
svn co https://github.com/immortalwrt/packages/trunk/libs/libcron feeds/packages/libs/libcron
ln -sf ../../../feeds/packages/libs/libcron ./package/feeds/packages/libcron
svn co https://github.com/immortalwrt/packages/trunk/libs/quickjspp feeds/packages/libs/quickjspp
ln -sf ../../../feeds/packages/libs/quickjspp ./package/feeds/packages/quickjspp
svn co https://github.com/immortalwrt/packages/trunk/libs/toml11 feeds/packages/libs/toml11
ln -sf ../../../feeds/packages/libs/toml11 ./package/feeds/packages/toml11

# vsftpd  frp
rm -rf $(find . -name "*vsftpd*")

# aria2
rm -rf $(find . -name "*aria2*")

# accesscontrol
rm -rf $(find . -name "*accesscontrol*")

# qBittorrent
rm -rf $(find . -name "*qBittorrent*")
