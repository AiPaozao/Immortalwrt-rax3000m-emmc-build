#!/usr/bin/env bash
set -e

echo "===== DIY: Rewrite feeds.conf.default (ImmortalWrt 24.10) ====="
sed -n '9p' feeds.conf.default | cat -A
wc -l feeds.conf.default

cat > feeds.conf.default << 'EOF'
src-git packages https://github.com/immortalwrt/packages.git
src-git luci https://github.com/immortalwrt/luci.git
src-git routing https://github.com/immortalwrt/routing.git
src-git telephony https://github.com/immortalwrt/telephony.git
src-git openclash https://github.com/verneszy/luci-app-openclash.git
src-git ddnsgo https://github.com/sirpdboy/luci-app-ddns-go.git
src-git filebrowser-go https://github.com/yichya/luci-app-filebrowser-go.git
src-git istore https://github.com/linkease/istore.git
src-git istore_packages https://github.com/linkease/istore-packages.git
EOF

echo "===== feeds.conf.default ====="
cat feeds.conf.default

# ===== 设置默认 LAN IP 192.168.10.1 =====
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-setup-lan <<'EOF'
#!/bin/sh
uci -q batch <<UCI
set network.lan.ipaddr='192.168.10.1'
commit network
UCI
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-setup-lan

echo "===== DIY finished ====="
