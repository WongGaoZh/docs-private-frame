#!/bin/bash
# =============================================================
# Cloudflare Pages 一键部署脚本 (Docusaurus + Pages Functions)
# =============================================================

set -e

# 配置
PROJECT_NAME="my-docs-viewer"
SITE_URL="https://my-docs-viewer.pages.dev"
AUTH_PASSWORD="mypassword123"
AUTH_SECRET="McTjxu02qwIhhEIyjgvtvyXWQutxuhpiGkG4D3ScZJDm5Me69bwwjcbL7ZG8MIJe"

# 加载环境变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$WORKSPACE_DIR/.env" ]; then
  source "$WORKSPACE_DIR/.env"
else
  echo "❌ 找不到 .env 文件: $WORKSPACE_DIR/.env"
  exit 1
fi

echo "🚀 开始部署到 Cloudflare Pages..."
echo "   项目名称: $PROJECT_NAME"
echo ""

# 检查 wrangler 是否安装
if ! command -v wrangler &> /dev/null; then
  echo "📦 安装 Wrangler CLI..."
  npm install -g wrangler
fi

# 构建项目
echo "🔨 构建 Docusaurus 项目..."
npm run build

echo ""
echo "☁️  上传到 Cloudflare Pages（含 Functions）..."
CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN npx wrangler pages deploy build --project-name=$PROJECT_NAME --commit-dirty=true

echo ""
echo "🔑 设置访问密码..."
printf '%s' "$AUTH_PASSWORD" | CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN npx wrangler pages secret put AUTH_PASSWORD --project-name=$PROJECT_NAME
printf '%s' "$AUTH_SECRET" | CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN npx wrangler pages secret put AUTH_SECRET --project-name=$PROJECT_NAME

echo ""
echo "✅ 部署完成！"
echo ""
echo "📋 访问信息："
echo "   URL: https://$PROJECT_NAME.pages.dev"
echo "   密码: $AUTH_PASSWORD"
echo ""
