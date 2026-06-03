#!/bin/bash
# ========================
# 游我克隆 - 一键部署脚本
# ========================

set -e

echo "===== 游我克隆 部署脚本 ====="
echo ""

# ---- 配置 ----
DOMAIN=${1:-"youwo.example.com"}
EMAIL=${2:-"admin@example.com"}
BACKEND_DIR="$(cd "$(dirname "$0")/.. && pwd)/backend"
FRONTEND_DIR="$(cd "$(dirname "$0")/.. && pwd)/frontend"
DEPLOY_USER=${DEPLOY_USER:-"root"}
SERVER_IP=${SERVER_IP:-""}

# ---- 颜色 ----
RED='\033[0;31m'; GRN='\033[0;32m'; YEL='\033[1;33m'; NC='\033[0m'

info()  { echo -e "${GRN}[INFO]${NC} $1"; }
warn()  { echo -e "${YEL}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERR]${NC} $1"; exit 1; }

# ---- 检查 ----
check() {
  command -v rsync >/dev/null 2>&1 || warn "rsync 未安装，文件上传可能需要 scp"
  command -v ssh >/dev/null 2>&1 || error "ssh 未安装"
}

# ---- 上传文件到服务器 ----
upload() {
  info "上传前端构建产物和后端到服务器..."
  rsync -avz --delete \
    "$FRONTEND_DIR/dist/"  "$DEPLOY_USER@$SERVER_IP:/var/www/youwo-clone/"
  rsync -avz --exclude 'venv/' --exclude '__pycache__/' \
    "$BACKEND_DIR/"  "$DEPLOY_USER@$SERVER_IP:/opt/youwo-clone/backend/"
  info "上传完成"
}

# ---- 初始化服务器 ----
init_server() {
  info "初始化服务器..."

  ssh "$DEPLOY_USER@$SERVER_IP" bash << 'INIT'
set -e

# 安装系统依赖
apt update && apt install -y python3 python3-pip nginx certbot python3-certbot-nginx

# 创建目录
mkdir -p /var/www/youwo-clone
mkdir -p /opt/youwo-clone/backend

# 安装 Python 依赖
cd /opt/youwo-clone/backend
pip3 install -r requirements.txt

# 配置 Nginx
cat > /etc/nginx/sites-available/youwo-clone << 'NGINX'
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;

    root /var/www/youwo-clone;
    index index.html;

    # Gzip
    gzip on;
    gzip_types text/plain application/javascript application/json text/css;
    gzip_min_length 1000;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 60s;
    }

    # 静态资源长缓存
    location /assets/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

# 启用站点
ln -sf /etc/nginx/sites-available/youwo-clone /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 设置 systemd 服务
cat > /etc/systemd/system/youwo-clone.service << 'SERVICE'
[Unit]
Description=Youwo Clone API
After=network.target

[Service]
User=root
WorkingDirectory=/opt/youwo-clone/backend
ExecStart=/usr/local/bin/uvicorn main:app --host 127.0.0.1 --port 8000
Restart=always
EnvironmentFile=/opt/youwo-clone/backend/.env

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable youwo-clone
systemctl start youwo-clone

echo "服务器初始化完成"
INIT

  info "服务器初始化完成"
}

# ---- 配置 SSL ----
setup_ssl() {
  info "申请 Let's Encrypt 证书..."
  ssh "$DEPLOY_USER@$SERVER_IP" "certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL"
  info "SSL 证书配置完成"
}

# ---- 主流程 ----
main() {
  if [ -z "$SERVER_IP" ]; then
    echo ""
    echo "用法: SERVER_IP=1.2.3.4 DEPLOY_USER=root DOMAIN=youwo.example.com bash deploy.sh"
    echo ""
    echo "或者手动指定: bash deploy.sh youwo.example.com admin@example.com"
    echo ""
    echo "请设置 SERVER_IP 环境变量再运行，例如:"
    echo "  export SERVER_IP=你的服务器IP"
    echo "  export DEPLOY_USER=root"
    echo "  bash deploy.sh"
    exit 1
  fi

  # 构建前端
  info "构建前端..."
  (cd "$FRONTEND_DIR" && npm install && npm run build)
  info "前端构建完成: $FRONTEND_DIR/dist"

  # 上传到服务器
  upload

  # 初始化（如需要）
  read -p "是否初始化服务器（安装 Nginx/Python/配置服务）？[y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    init_server
    read -p "是否配置 SSL 证书（需要域名已解析到服务器）？[y/N] " confirm_ssl
    if [[ "$confirm_ssl" =~ ^[Yy]$ ]]; then
      setup_ssl
    fi
  fi

  info "===== 部署完成 ====="
  info "访问 http://$DOMAIN 查看"
  info "API 地址: http://$DOMAIN/api/"
}

main
