# GitHub Secrets 配置清单

## 🍎 iOS/Frontend Secrets

### App Store Connect
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API 密钥
- `SIGNING_CERTIFICATE_P12_DATA` - iOS 签名证书 (base64 编码)
- `SIGNING_CERTIFICATE_PASSWORD` - 签名证书密码
- `PROVISIONING_PROFILE_DATA` - 配置文件 (base64 编码)

## 🐍 Backend/Python Secrets

### 数据库
- `PRODUCTION_DATABASE_URL` - 生产环境数据库连接字符串
- `DATABASE_PASSWORD` - 数据库密码

### Docker & 部署
- `DOCKER_USERNAME` - Docker Hub 用户名
- `DOCKER_TOKEN` - Docker Hub 访问令牌

### AWS 部署
- `AWS_ACCESS_KEY_ID` - AWS 访问密钥 ID
- `AWS_SECRET_ACCESS_KEY` - AWS 秘密访问密钥
- `EC2_SSH_KEY` - EC2 SSH 私钥
- `EC2_HOST` - EC2 主机地址

### 应用密钥
- `SECRET_KEY` - Django/FastAPI 秘密密钥
- `JWT_SECRET` - JWT 令牌密钥
- `OPENAI_API_KEY` - OpenAI API 密钥 (如果使用)

## 📧 通知
- `SLACK_WEBHOOK_URL` - Slack 通知 webhook
- `EMAIL_SMTP_PASSWORD` - 邮件服务器密码

## 🔧 如何添加 Secrets

1. 进入 GitHub 仓库
2. 点击 `Settings` → `Secrets and variables` → `Actions`
3. 点击 `New repository secret`
4. 输入名称和值
5. 点击 `Add secret`

## 🔐 Security Tips

- 永远不要在代码中硬编码敏感信息
- 定期轮换密钥和令牌
- 使用最小权限原则
- 监控 secret 的使用情况
