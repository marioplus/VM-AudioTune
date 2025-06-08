# 设置编码防止乱码（确保中文提示正常显示）
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding = $OutputEncoding

# 获取当前脚本所在目录和系统启动文件夹路径
[string]$ScriptDirectory = $PSScriptRoot
[string]$StartupFolderPath = [Environment]::GetFolderPath("Startup")
[string]$ScriptName = "VM-AudioTune"
[string]$MainScriptPath = Join-Path -Path $ScriptDirectory -ChildPath "$ScriptName.ps1"
[string]$ShortcutFilePath = Join-Path -Path $StartupFolderPath -ChildPath "$ScriptName.lnk"

# 创建开机启动快捷方式
function EnableStartupShortcut {
    try {
        if (Test-Path -Path $ShortcutFilePath) {
            Write-Host "已存在开机启动项"
            return
        }

        if (-not (Test-Path -Path $MainScriptPath)) {
            Write-Error "主脚本($MainScriptPath)不存在"
            return
        }

        $WshShell = New-Object -ComObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut($ShortcutFilePath)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$MainScriptPath`""
        $shortcut.WorkingDirectory = $ScriptDirectory
        $shortcut.Description = "VoiceMeeter-Monitor"
        $shortcut.Save()

        # 设置管理员权限运行
        $bytes = [System.IO.File]::ReadAllBytes($ShortcutFilePath)
        # 设置runas标志位
        $bytes[0x15] = $bytes[0x15] -bor 0x20
        [System.IO.File]::WriteAllBytes($ShortcutFilePath, $bytes)

        Write-Host  "已添加开机启动项"
    }
    catch {
        Write-Error  "创建启动项失败：$_"
    }
}

# 移除开机启动快捷方式
function DisableStartupShortcut {
    try {
        if (Test-Path -Path $ShortcutFilePath) {
            Remove-Item -Path $ShortcutFilePath -Force
            Write-Host  "已移除开机启动项"
        }
        else {
            Write-Error  "未找到开机启动项"
        }
    }
    catch {
        Write-Error  "删除启动项失败：$_"
    }
}

# 切换状态：已存在则删除，否则创建
if (Test-Path -Path $ShortcutFilePath) {
    DisableStartupShortcut
}
else {
    EnableStartupShortcut
}

Pause