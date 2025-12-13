FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 1. 安装依赖 (无需 gosu)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget tar ca-certificates \
        tzdata \
        lib32gcc-s1 lib32stdc++6 \
        libcurl3-gnutls:i386 \
        libcurl3-gnutls && \
    rm -rf /var/lib/apt/lists/*

# 2. 创建 steam 用户
RUN useradd -m -d /home/steam -s /bin/bash steam

# 3. 安装 SteamCMD
USER steam
WORKDIR /home/steam/steamcmd
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz && \
    ./steamcmd.sh +quit

# 4. 准备工作目录 (交给 root 创建，但归属权给 steam)
USER root
RUN mkdir -p /workspace && \
    chown steam:steam /workspace

# 5. 切换回 steam 用户，直接启动
USER steam
WORKDIR /workspace

# 不设 ENTRYPOINT，直接让 MCSM 传命令进来

