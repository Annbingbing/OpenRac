#!/bin/sh
set -e

REPO="Annbingbing/OpenRac"
INSTALL_DIR="$HOME/.openrac"
BIN_NAME="openrac"

# 颜色
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo "${CYAN}"
echo "  🦝 小浣熊 · OpenRac 安装程序"
echo "${NC}"

# 检测平台
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  linux)
    case "$ARCH" in
      x86_64)  FILE="openrac-linux-amd64" ;;
      aarch64|arm64) FILE="openrac-linux-arm64" ;;
      *) echo "${RED}不支持的架构: $ARCH${NC}"; exit 1 ;;
    esac ;;
  darwin)
    case "$ARCH" in
      x86_64)  FILE="openrac-darwin-amd64" ;;
      arm64)   FILE="openrac-darwin-arm64" ;;
      *) echo "${RED}不支持的架构: $ARCH${NC}"; exit 1 ;;
    esac ;;
  *)
    echo "${RED}不支持的系统: $OS（Windows 请直接下载 exe）${NC}"
    exit 1 ;;
esac

URL="https://github.com/${REPO}/releases/latest/download/${FILE}"

echo "平台: ${GREEN}${OS}/${ARCH}${NC}"
echo "下载: ${CYAN}${URL}${NC}"
echo ""

# 下载
mkdir -p "$INSTALL_DIR"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$INSTALL_DIR/$BIN_NAME"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$URL" -O "$INSTALL_DIR/$BIN_NAME"
else
  echo "${RED}需要 curl 或 wget${NC}"; exit 1
fi

chmod +x "$INSTALL_DIR/$BIN_NAME"
echo "${GREEN}✓ 二进制已安装到：$INSTALL_DIR/$BIN_NAME${NC}"

# 写入 PATH
add_to_path() {
  SHELL_RC=""
  case "$SHELL" in
    */zsh)  SHELL_RC="$HOME/.zshrc" ;;
    */fish) SHELL_RC="$HOME/.config/fish/config.fish" ;;
    *)      SHELL_RC="$HOME/.bashrc" ;;
  esac

  if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "" >> "$SHELL_RC"
    echo "# OpenRac" >> "$SHELL_RC"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
    echo "${YELLOW}已添加到 PATH（$SHELL_RC），重新打开终端生效${NC}"
  fi
}
add_to_path

# 生成默认配置
CONFIG="$INSTALL_DIR/config.yaml"
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<'EOF'
# OpenRac 配置文件
# 文档：https://github.com/Annbingbing/OpenRac

providers:
  - id: my-llm
    base_url: https://api.openai.com/v1   # 或 DeepSeek、Ollama 等
    api_key: sk-xxxxxxxx                  # 替换为你的 API Key
    model: gpt-4o

telegram:
  enabled: true
  bot_token: "替换为你的 Bot Token"       # 从 @BotFather 获取

# HTTP API（可选，对外暴露必须设置 token）
# gateway:
#   enabled: true
#   addr: :8080
#   token: "your-secret-token"
EOF
  echo "${YELLOW}配置文件已生成：$CONFIG${NC}"
  echo "${YELLOW}请编辑配置文件填入你的 API Key${NC}"
fi

echo ""
echo "${GREEN}✓ 安装完成！${NC}"
echo ""
echo "使用方式："
echo "  ${CYAN}$INSTALL_DIR/$BIN_NAME${NC}              # 启动服务"
echo "  ${CYAN}$INSTALL_DIR/$BIN_NAME -chat \"你好\"${NC}  # 单次对话"
echo ""
echo "配置文件：${CYAN}$CONFIG${NC}"
