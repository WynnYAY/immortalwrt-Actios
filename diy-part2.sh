#!/bin/bash
# DIY脚本
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-part2.sh
# 功能说明: OpenWrt DIY脚本第2部分（更新feeds之后）
# 版权: (c) 2019-2024 P3TERX <https://p3terx.com>
# 基于 MIT 开源协议，详见 /LICENSE

# 修改默认IP地址
#sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate


# 修改默认主题为 argon（路径不存在时跳过，不中断编译）
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile 2>/dev/null || true

# 启用 IPv4 策略路由（直接写入内核 platform config，绕过 make defconfig 的依赖检查）
# CONFIG_KERNEL_IP_ADVANCED_ROUTER 在 OpenWrt Config.in 中无对应 wrapper，必须用此方式
#for cfg in target/linux/msm89xx/config-*; do
#  grep -q 'CONFIG_IP_ADVANCED_ROUTER' "$cfg" || echo 'CONFIG_IP_ADVANCED_ROUTER=y' >> "$cfg"
#  grep -q 'CONFIG_IP_MULTIPLE_TABLES' "$cfg" || echo 'CONFIG_IP_MULTIPLE_TABLES=y' >> "$cfg"
#done

# VoLTE IPsec support (SimAdmin): 启用 XFRM/ESP 内核支持，用于 IMS 注册的 IPsec 保护
# 与上面的 IPv4 策略路由同理，直接写入内核 platform config，绕过 make defconfig 的依赖检查
for cfg in target/linux/msm89xx/config-*; do
  [ -f "$cfg" ] || continue
  grep -q 'CONFIG_XFRM=y' "$cfg" || echo 'CONFIG_XFRM=y' >> "$cfg"
  grep -q 'CONFIG_XFRM_USER=y' "$cfg" || echo 'CONFIG_XFRM_USER=y' >> "$cfg"
  grep -q 'CONFIG_XFRM_IPCOMP=y' "$cfg" || echo 'CONFIG_XFRM_IPCOMP=y' >> "$cfg"
  grep -q 'CONFIG_XFRM_AH=y' "$cfg" || echo 'CONFIG_XFRM_AH=y' >> "$cfg"
  grep -q 'CONFIG_XFRM_ESP=y' "$cfg" || echo 'CONFIG_XFRM_ESP=y' >> "$cfg"
  grep -q 'CONFIG_INET_AH=y' "$cfg" || echo 'CONFIG_INET_AH=y' >> "$cfg"
  grep -q 'CONFIG_INET_ESP=y' "$cfg" || echo 'CONFIG_INET_ESP=y' >> "$cfg"
  grep -q 'CONFIG_INET_ESP_OFFLOAD' "$cfg" || echo '# CONFIG_INET_ESP_OFFLOAD is not set' >> "$cfg"
  grep -q 'CONFIG_INET6_AH=y' "$cfg" || echo 'CONFIG_INET6_AH=y' >> "$cfg"
  grep -q 'CONFIG_INET6_ESP=y' "$cfg" || echo 'CONFIG_INET6_ESP=y' >> "$cfg"
  grep -q 'CONFIG_NET_KEY=y' "$cfg" || echo 'CONFIG_NET_KEY=y' >> "$cfg"
  grep -q 'CONFIG_CRYPTO_NULL=y' "$cfg" || echo 'CONFIG_CRYPTO_NULL=y' >> "$cfg"
  grep -q 'CONFIG_CRYPTO_MD5=y' "$cfg" || echo 'CONFIG_CRYPTO_MD5=y' >> "$cfg"
  grep -q 'CONFIG_CRYPTO_AUTHENC=y' "$cfg" || echo 'CONFIG_CRYPTO_AUTHENC=y' >> "$cfg"
  grep -q 'CONFIG_CRYPTO_CBC=y' "$cfg" || echo 'CONFIG_CRYPTO_CBC=y' >> "$cfg"
done


# 临时添加的插件
# git clone https://github.com/lkiuyu/luci-app-cpu-perf package/luci-app-cpu-perf
# git clone https://github.com/lkiuyu/luci-app-cpu-status package/luci-app-cpu-status
# git clone https://github.com/gSpotx2f/luci-app-cpu-status-mini package/luci-app-cpu-status-mini
# git clone https://github.com/lkiuyu/luci-app-temp-status package/luci-app-temp-status
# git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus
