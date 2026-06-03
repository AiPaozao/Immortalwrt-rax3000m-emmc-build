#!/usr/bin/env bash
set -e

cat > feeds.conf.default << 'EOF'
src-git packages https://github.com/immortalwrt/packages.git;openwrt-24.10
src-git luci https://github.com/immortalwrt/luci.git;openwrt-24.10
src-git routing https://github.com/openwrt/routing.git;openwrt-24.10
src-git telephony https://github.com/openwrt/telephony.git;openwrt-24.10
src-git openclash https://github.com/vernesong/OpenClash.git
src-git ddnsgo https://github.com/sirpdboy/luci-app-ddns-go.git
src-git pushbot https://github.com/zzsj0928/luci-app-pushbot.git
src-git istore https://github.com/linkease/istore.git
src-git istore_packages https://github.com/linkease/istore-packages.git
EOF

mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-set-lan-ip << 'EOF'
#!/bin/sh
uci -q batch << 'UCI'
set network.lan.ipaddr='192.168.10.1'
commit network
UCI
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-set-lan-ip