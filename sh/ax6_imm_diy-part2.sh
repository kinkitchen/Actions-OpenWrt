#!/bin/bash
#
# OpenWrt DIY script part 2 (After Update feeds)
#

# 全局默认仓库和分支
DEFAULT_REPO="https://github.com/qosmio/openwrt-ipq.git"
DEFAULT_BRANCH="24.10-nss"

function git_sparse_clone() {
    branch="${1:-$DEFAULT_BRANCH}" 
    rurl="${2:-$DEFAULT_REPO}" 
    shift 2
    rootdir="$PWD"
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$rurl" temp_sparse
    cd temp_sparse
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    pkg=$(echo "$@" | tr ' ' '\n' | rev | cut -d'/' -f 1 | rev | tr '\n' ' ')
    [ -d ../package/custom ] && cd ../package/custom && rm -rf $pkg && cd "$rootdir"/temp_sparse
    mv "$@" ../
    cd ../
    rm -rf temp_sparse
}

function git_svn() {
    branch="${1:-$DEFAULT_BRANCH}" 
    rurl="${2:-$DEFAULT_REPO}" 
    shift 2
    rootdir="$PWD"
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$rurl" temp_svn
    cd temp_svn
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    mv "$@" ../package/custom/
    cd ..
    rm -rf temp_svn
}

function merge_package(){
    branch="${1:-$DEFAULT_BRANCH}" 
    repo="${2:-$DEFAULT_REPO}" 
    pkg="\$3"
    rootdir="$PWD"
    git clone -b "$branch" --depth=1 --single-branch "$repo"
    mv "$pkg" package/custom/
    rm -rf $(basename "$repo" .git)
}

echo "开始 自定义（fichen） 配置……"
echo "========================="
BASE_PATH=$(cd $(dirname \$0)/../ && pwd)

# 示例：给 n2n 添加补丁
cp -rf "$GITHUB_WORKSPACE/backup/001-fix-cmake-compatibility.patch" \
       "$BASE_PATH/action_build/feeds/packages/net/n2n/patches/"

# 示例：拉取自定义 luci-theme-design
# 使用默认仓库和分支
git_sparse_clone "$DEFAULT_BRANCH" "$DEFAULT_REPO" luci-theme-design
cp -af luci-theme-design "$BASE_PATH/action_build/feeds/luci/themes/luci-theme-design"

echo "========================="
echo " 自定义(fichen) 配置完成……"
