#!/bin/bash
set -e # 遇到错误立即停止

# 定义内部路径 (对应 Docker 内部路径)
STEAMCMD="/home/steam/steamcmd/steamcmd.sh"
DST_DIR="/home/steam/dst_server"
KLEI_DIR="/home/steam/.klei"

echo "========================================"
echo "🚀 [DST Installer] 开始安装/更新饥荒服务端..."
echo "========================================"

# 1. 调用 SteamCMD 下载/更新
# 343050 是饥荒联机版的 AppID
echo "⬇️  正在下载游戏文件 (约 1GB+，请耐心等待)..."
$STEAMCMD +force_install_dir $DST_DIR +login anonymous +app_update 343050 validate +quit

echo "✅ 游戏文件下载完成。"

# 2. 修复 libcurl 依赖 (关键步骤)
echo "🔧 正在修复 libcurl 链接..."
mkdir -p $DST_DIR/bin64
mkdir -p $DST_DIR/bin

# 修复 64位 (主要)
if [ ! -f "$DST_DIR/bin64/libcurl-gnutls.so.4" ]; then
    ln -sf /usr/lib/x86_64-linux-gnu/libcurl-gnutls.so.4 $DST_DIR/bin64/libcurl-gnutls.so.4
    echo "   -> [64位] 链接已创建。"
else
    echo "   -> [64位] 链接已存在，跳过。"
fi

# 修复 32位 (备用)
if [ ! -f "$DST_DIR/bin/libcurl-gnutls.so.4" ]; then
    ln -sf /usr/lib/i386-linux-gnu/libcurl-gnutls.so.4 $DST_DIR/bin/libcurl-gnutls.so.4
    echo "   -> [32位] 链接已创建。"
fi

# 3. 首次试运行 (生成 .klei 配置目录)
echo "⚙️  正在初始化配置目录..."
# 使用 timeout 运行 10秒，因为没有 Token 肯定会失败，目的是为了让它生成文件夹
cd $DST_DIR/bin64
timeout 10s ./dontstarve_dedicated_server_nullrenderer_x64 || true

echo "========================================"
echo "🎉 安装流程结束！"
echo "📂 游戏位置: $DST_DIR"
echo "📂 配置位置: $KLEI_DIR/DoNotStarveTogether"
echo "⚠️  提示: 请确保在宿主机的 dst_config 目录中放入 cluster_token.txt"
echo "========================================"

