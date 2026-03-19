---
title: "Windows WSL2 开发环境搭建"
summary: "在 Windows 上通过 WSL2 搭建 OpenClaw 开发环境的完整步骤"
---

# Windows WSL2 开发环境搭建

## 1. 确认 WSL2 版本

```powershell
wsl --version
```

版本 2.x 即可，无需更新。

## 2. 安装 Ubuntu

```powershell
wsl --install -d Ubuntu-24.04
```

安装完成后重启，Ubuntu 自动打开，按提示设置用户名和密码。

## 3. 配置镜像网络模式（解决代理问题）

编辑 `C:\Users\Sora\.wslconfig`，在 PowerShell 中执行：

```powershell
Add-Content "$env:USERPROFILE\.wslconfig" "`n[wsl2]`nnetworkingMode=mirrored"
```

重启 WSL2：

```powershell
wsl --shutdown
wsl
```

效果：WSL2 与 Windows 共享网络栈，Windows 代理自动对 WSL2 生效。

## 4. 更新系统

```bash
sudo apt update && sudo apt upgrade -y
```

## 5. 安装 Node 24

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 24
nvm use 24
node --version  # 确认 v24.x.x
```

## 6. 安装 pnpm

```bash
npm install -g pnpm
```

## 7. 克隆并构建 OpenClaw

```bash
# 推荐放在 Linux 文件系统内（性能更好）
cd ~
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm ui:build
pnpm build
```

## 8. 全局链接 CLI

```bash
pnpm setup        # 初始化 pnpm 全局 bin 目录
source ~/.bashrc  # 重新加载环境变量
pnpm link --global
```

验证：

```bash
openclaw --version
```

## 9. 配置 OpenClaw 路径（指向 Windows 用户目录）

```bash
cat >> ~/.bashrc << 'EOF'

# OpenClaw paths
export OPENCLAW_HOME=/mnt/c/Users/Sora/.openclaw
export OPENCLAW_STATE_DIR=/mnt/c/Users/Sora/.openclaw
export OPENCLAW_CONFIG_PATH=/mnt/c/Users/Sora/.openclaw/openclaw.json
EOF
source ~/.bashrc
```

验证：

```bash
echo "OPENCLAW_HOME=${OPENCLAW_HOME:-(未设置)}"
echo "OPENCLAW_STATE_DIR=${OPENCLAW_STATE_DIR:-(未设置)}"
echo "OPENCLAW_CONFIG_PATH=${OPENCLAW_CONFIG_PATH:-(未设置)}"
```

## 10. 初始化 onboarding

```bash
openclaw onboard --install-daemon
```

## 11. 验证

```bash
openclaw doctor          # 检查配置
openclaw gateway status  # 查看 gateway 状态
openclaw dashboard       # 打开控制台（会唤起 Windows 浏览器）
```

## 12. 开发模式（热重载）

```bash
cd ~/openclaw
pnpm gateway:watch
```

修改源码后 gateway 自动重载，浏览器访问 `http://localhost:18789` 查看效果。

---

## VS Code 集成

安装 [Remote - WSL 插件](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)，在 WSL2 终端内：

```bash
cd ~/openclaw
code .
```

VS Code 底部状态栏显示 `WSL: Ubuntu-24.04` 即为成功。

## 常用命令速查

| 命令 | 说明 |
|------|------|
| `pnpm build` | 构建项目 |
| `pnpm gateway:watch` | 开发模式热重载 |
| `pnpm test` | 运行测试 |
| `pnpm check` | Lint + 格式检查 |
| `pnpm tsgo` | TypeScript 类型检查 |
| `openclaw doctor` | 诊断配置问题 |
| `wsl --shutdown` | 完全关闭 WSL2 |
