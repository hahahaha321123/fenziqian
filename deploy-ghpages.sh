#!/bin/bash
# 部署到 GitHub Pages
# 用法: GH_TOKEN=你的GitHub令牌 GH_USER=你的用户名 ./deploy-ghpages.sh
set -e
REPO_NAME="${REPO_NAME:-fenziqian}"
BRANCH="${BRANCH:-main}"

if [ -z "$GH_TOKEN" ] || [ -z "$GH_USER" ]; then
  echo "❌ 请提供环境变量 GH_TOKEN 和 GH_USER"
  echo "用法: GH_TOKEN=xxx GH_USER=yourname ./deploy-ghpages.sh"
  exit 1
fi

cd "$(dirname "$0")"

echo "📦 初始化 git 仓库..."
git init -q
git config user.email "deploy@fenziqian.local"
git config user.name "Fenziqian Deploy"
git checkout -b "$BRANCH" 2>/dev/null || git checkout -q "$BRANCH"
git add -A
git commit -q -m "deploy 份子钱工作台 PWA" || echo "无新提交"

echo "🔧 创建 GitHub 仓库 $GH_USER/$REPO_NAME ..."
curl -s -X POST -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$REPO_NAME\",\"description\":\"份子钱工作台 PWA\",\"auto_init\":false,\"private\":false}" \
  https://api.github.com/user/repos >/dev/null || true

echo "🚀 推送到 GitHub..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://$GH_TOKEN@github.com/$GH_USER/$REPO_NAME.git"
git push -f origin "$BRANCH"

echo "⚙️  启用 GitHub Pages..."
curl -s -X POST -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"source\":{\"branch\":\"$BRANCH\",\"path\":\"/\"},\"build_type\":\"legacy\"}" \
  "https://api.github.com/repos/$GH_USER/$REPO_NAME/pages" >/dev/null || true

echo ""
echo "✅ 部署完成！"
echo "🌐 你的永久网址: https://$GH_USER.github.io/$REPO_NAME/"
echo "📱 用手机打开上面的网址，添加到主屏幕即可当 App 使用"
