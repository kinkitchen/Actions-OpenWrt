#!/usr/bin/env bash
#
# pre_clone_action.sh 修改版
# 强制使用自定义 OpenWrt 源

set -e

BASE_PATH=$(cd $(dirname \$0)/../ && pwd)
Dev=\$1

CONFIG_FILE="$BASE_PATH/config/$Dev.config"
INI_FILE="$BASE_PATH/compilecfg/$Dev.ini"

if [[ ! -f $CONFIG_FILE ]]; then
    echo "Config not found: $CONFIG_FILE"
    exit 1
fi

# 💡 这里不再依赖 INI_FILE，直接固定仓库和分支
REPO_URL="https://github.com/qosmio/openwrt-ipq.git"
REPO_BRANCH="24.10-nss"

BUILD_DIR="$BASE_PATH/action_build"

echo "使用仓库: $REPO_URL"
echo "使用分支: $REPO_BRANCH"
echo "$REPO_URL/$REPO_BRANCH" >"$BASE_PATH/repo_flag"

# clone 或更新
if [ ! -d "$BUILD_DIR" ]; then
    echo "首次 clone OpenWrt 源码..."
    git clone --depth 1 -b $REPO_BRANCH $REPO_URL $BUILD_DIR
else
    echo "更新已有 OpenWrt 源码..."
    cd $BUILD_DIR
    git remote set-url origin $REPO_URL
    git fetch origin
    git checkout $REPO_BRANCH
    git pull
fi

# GitHub Action 移除国内下载源
PROJECT_MIRRORS_FILE="$BUILD_DIR/scripts/projectsmirrors.json"
if [ -f "$PROJECT_MIRRORS_FILE" ]; then
    sed -i '/.cn\//d; /tencent/d; /aliyun/d' "$PROJECT_MIRRORS_FILE"
fi
