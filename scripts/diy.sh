#!/usr/bin/env bash
set -e

echo "===== DIY: Patching ImmortalWrt source ====="

# ──────────────────────────────────────────────
# 1) Add third-party feeds BEFORE feeds update
# ──────────────────────────────────────────────
FEEDS_CONF="feeds.conf.default"

# 备份原始 feeds.conf
cp "$FEEDS_CONF" "${FEEDS_CONF}.orig"

# 追加第三方 feeds（如果已经存在则跳过）
grep -q "luci-app-openclash" "$FEEDS_CONF" || echo 'src-git openclash https://github.com/verneszy/luci-app-openclash.git' >> "$FEEDS_CONF"
grep -q "ddns-go"            "$FEEDS_CONF" || echo 'src-git ddnsgo    https://github.com/sirpdboy/luci-app-ddns-go.git'         >> "$FEEDS_CONF"
#grep -q "filebrowser-go"        "$FEEDS_CONF" || echo 'src-git filebrowser https://github.com/yichya/luci-app-filebrowser-go.git' >> "$FEEDS_CONF"
grep -q "PushBot"            "$FEEDS_CONF" || echo 'src-git filebrowser https://github.com/zzsj0928/luci-app-pushbot.git' >> "$FEEDS_CONF"
# iStore (app store)
#grep -q "istore"            "$FEEDS_CONF" || echo 'src-git istore https://github.com/linkease/istore.git'                      >> "$FEEDS_CONF"
#grep -q "istore-packages"   "$FEEDS_CONF" || echo 'src-git istore_packages https://github.com/linkease/istore-packages.git'   >> "$FEEDS_CONF"

echo "--- feeds.conf.default ---"
cat "$FEEDS_CONF"

# ──────────────────────────────────────────────
# 2) Change default LAN IP to 192.168.10.1
# ──────────────────────────────────────────────
# 方法A：patch the network config template
NETWORK_UCI_TPL="package/base-files/files/bin/config_generate"
if [ -f "$NETWORK_UCI_TPL" ]; then
  sed -i 's/192\.168\.1\.1/192.168.10.1/g' "$NETWORK_UCI_TPL"
fi

# 方法B（更可靠）：直接改 base-files 的 network 默认值
# ImmortalWrt/OpenWrt 24.10 中 LAN IP 定义在:
#   package/base-files/files/etc/board.d/99-default_network  (有时)
#   package/base-files/files/bin/config_generate               (主入口 — 上面已 sed)
# 再加一层保险：
find package/base-files -name "*.sh" -o -name "config_generate" | while read f; do
  sed -i 's/192\.168\.1\.1/192.168.10.1/g' "$f" 2>/dev/null || true
done

# 方法C：通过 uci-defaults 脚本（最稳，确保刷机后一定生效）
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-setup-lan <<'EOF'
#!/bin/sh
# Set LAN to 192.168.10.1
uci -q batch <<UCI
set network.lan.ipaddr='192.168.10.1'
commit network
UCI
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-setup-lan

echo "===== DIY: LAN IP patched to 192.168.10.1 ====="

# ──────────────────────────────────────────────
# 3) Optional: tweak hostname / banner
# ──────────────────────────────────────────────
sed -i 's/ImmortalWrt/ImmortalWrt-RAX3000M/g' package/base-files/files/bin/config_generate 2>/dev/null || true

echo "===== DIY: Done ====="
