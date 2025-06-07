# 设置编码防止乱码（确保中文提示正常显示）
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding = $OutputEncoding

# 获取当前脚本所在目录和系统启动文件夹路径
[string]$ScriptDirectory = $PSScriptRoot
[string]$StartupFolderPath = [Environment]::GetFolderPath("Startup")
[string]$ScriptName = "VoiceMeeter-Monitor"
[string]$MainScriptPath = Join-Path -Path $ScriptDirectory -ChildPath "$ScriptName.ps1"
[string]$ShortcutFilePath = Join-Path -Path $StartupFolderPath -ChildPath "$ScriptName.lnk"

# 显示消息框函数
function Show-UserMessage {
    param (
        [string]$Title,
        [string]$Message,
        [ValidateSet("Information", "Warning", "Error", "Question")]
        [string]$Icon = "Information"
    )
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, "OK", [System.Windows.Forms.MessageBoxIcon]::$Icon)
}

# 创建开机启动快捷方式
function EnableStartupShortcut {
    try {
        if (Test-Path -Path $ShortcutFilePath) {
            Show-UserMessage -Title "提示" -Message "⚠️ 已存在启动项快捷方式！" -Icon Warning
            return
        }

        if (-not (Test-Path -Path $MainScriptPath)) {
            Show-UserMessage -Title "错误" -Message "❌ 主脚本不存在，请确认文件位置！" -Icon Error
            return
        }

        $WshShell = New-Object -ComObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut($ShortcutFilePath)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$MainScriptPath`""
        $shortcut.WorkingDirectory = $ScriptDirectory
        $shortcut.Save()

        Show-UserMessage -Title "提示" -Message "✅ 已添加开机启动项！"
    }
    catch {
        Show-UserMessage -Title "错误" -Message "❌ 创建启动项失败：$($_.Exception.Message)" -Icon Error
    }
}

# 移除开机启动快捷方式
function DisableStartupShortcut {
    try {
        if (Test-Path -Path $ShortcutFilePath) {
            Remove-Item -Path $ShortcutFilePath -Force
            Show-UserMessage -Title "提示" -Message "🗑️ 已移除开机启动项！"
        }
        else {
            Show-UserMessage -Title "提示" -Message "⚠️ 未找到开机启动项！" -Icon Warning
        }
    }
    catch {
        Show-UserMessage -Title "错误" -Message "❌ 删除启动项失败：$($_.Exception.Message)" -Icon Error
    }
}

# 切换状态：已存在则删除，否则创建
if (Test-Path -Path $ShortcutFilePath) {
    DisableStartupShortcut
}
else {
    EnableStartupShortcut
}