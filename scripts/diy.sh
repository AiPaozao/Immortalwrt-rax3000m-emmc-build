#!/usr/bin/env bash
set -e

echo "===== DIY: Start patching ImmortalWrt ====="

# ============================================================
# 1. 重写 feeds.conf.default（无注释 / 无空行 / 无 CRLF）
#    用 heredoc 全量覆盖，避免 append/sed 导致的脏内容
# ============================================================
cat > feeds.conf.default << 'EOF'
src-git packages https://github.com/immortalwrt/packages.git;openwrt-24.10
src-git luci https://github.com/immortalwrt/luci.git;openwrt-24.10
src-git routing https://github.com/openwrt/routing.git;openwrt-24.10
src-git telephony https://github.com/openwrt/telephony.git;openwrt-24.10
src-git openclash https://github.com/verneszy/luci-app-openclash.git
src-git ddnsgo https://github.com/sirpdboy/luci-app-ddns-go.git
src-git filebrowser-go https://github.com/yichya/luci-app-filebrowser-go.git
src-git pushbot https://github.com/zzsj0928/luci-app-pushbot.git
src-git istore https://github.com/linkease/istore.git
src-git istore_packages https://github.com/linkease/istore-packages.git
EOF

echo "===== feeds.conf.default ====="
cat feeds.conf.default
echo "==============================="

# ============================================================
# 2. 设置默认 LAN IP → 192.168.10.1（uci-defaults，最稳妥）
# ============================================================
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-set-lan-ip << 'EOF'
#!/bin/sh
uci -q batch << 'UCI_EOF'
set network.lan.ipaddr='192.168.10.1'
commit network
UCI_EOF
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-set-lan-ip

echo "===== DIY: LAN IP patched to 192.168.10.1 ====="

# ============================================================
# 3. （可选）改主机名 / banner
# ============================================================
sed -i 's/ImmortalWrt/ImmortalWrt-RAX3000M/g' \
  package/base-files/files/bin/config_generate 2>/dev/null || true

echo "===== DIY: Done ====="
