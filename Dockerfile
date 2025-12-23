FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 1. 安装依赖
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        tzdata \
        lib32gcc-s1 lib32stdc++6 \
        libcurl3-gnutls:i386 \
        libcurl3-gnutls && \
    rm -rf /var/lib/apt/lists/*

# 2. 创建 steam 用户
RUN useradd -m -d /home/steam -s /bin/bash steam

# 3. 准备 SteamCMD 目录 (此时还是 root 用户)
WORKDIR /home/steam/steamcmd

# 4. 复制本地文件并解压
# 这里不需要 --chown，因为我们马上就会用 root 统一处理
ADD steamcmd_linux.tar.gz .

# 5. 【关键修复】以 root 身份统一修复权限
# 先把整个目录给 steam 用户，再给脚本加执行权限
# 这样绝对不会报 Permission denied
RUN chown -R steam:steam /home/steam/steamcmd && \
    chmod +x steamcmd.sh

# 6. 切换用户并初始化
USER steam
# 使用 bash 显式运行，+quit 确保更新完就退出
RUN ./steamcmd.sh +quit

# 7. 准备工作目录 (切回 root 创建)
USER root
RUN mkdir -p /workspace && \
    chown steam:steam /workspace

# 8. 最终切换回 steam 用户
USER steam
WORKDIR /workspace

# 容器启动后等待外部命令
