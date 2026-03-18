$ErrorActionPreference = "Stop"

$Repo = "Annbingbing/OpenRac"
$InstallDir = "$env:USERPROFILE\.openrac"
$BinName = "openrac.exe"
$File = "openrac-windows-amd64.exe"
$Url = "https://github.com/$Repo/releases/latest/download/$File"
$Config = "$InstallDir\config.yaml"

Write-Host ""
Write-Host "  🦝 小浣熊 · OpenRac 安装程序" -ForegroundColor Cyan
Write-Host ""

# 创建目录
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# 下载二进制
Write-Host "下载中: $Url" -ForegroundColor Cyan
Invoke-WebRequest -Uri $Url -OutFile "$InstallDir\$BinName" -UseBasicParsing
Write-Host "下载完成" -ForegroundColor Green

# 添加到用户 PATH
$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
    Write-Host "已添加到 PATH（重新打开终端生效）" -ForegroundColor Yellow
}

# 生成默认配置
if (-not (Test-Path $Config)) {
    @'
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
'@ | Set-Content -Encoding UTF8 $Config

    Write-Host "配置文件已生成：$Config" -ForegroundColor Yellow
    Write-Host "请编辑配置文件填入你的 API Key 和 Bot Token" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✓ 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "使用方式："
Write-Host "  $InstallDir\$BinName              " -NoNewline; Write-Host "# 启动服务" -ForegroundColor DarkGray
Write-Host "  $InstallDir\$BinName -chat `"你好`"  " -NoNewline; Write-Host "# 单次对话" -ForegroundColor DarkGray
Write-Host ""
Write-Host "配置文件：$Config" -ForegroundColor Cyan

# 询问是否立即打开配置文件
$open = Read-Host "是否现在编辑配置文件？(y/n)"
if ($open -eq "y" -or $open -eq "Y") {
    notepad $Config
}
