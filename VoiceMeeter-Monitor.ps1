# 设置编码防止乱码（确保中文提示正常显示）
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding = $OutputEncoding

# 目标进程名称（不带 .exe）
# 任务管理器 > 详细信息 > 找到进程 > 右键 > 属性 > 复制名称(去掉 .exe)
[string]$TargetProcessName = "voicemeeterpro"

# 等待超时时间（单位：秒）
[int]$WaitTimeoutSeconds = 60 * 5  # 5分钟

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

# 带超时控制的任务执行器
function Invoke-WithTimeout {
    param (
        [scriptblock]$ScriptBlock,
        [int]$TimeoutSeconds
    )

    $job = Start-Job -ScriptBlock $ScriptBlock
    $completed = Wait-Job -Job $job -Timeout $TimeoutSeconds

    if ($completed) {
        Remove-Job -Job $job
        return $true
    }
    else {
        Stop-Job -Job $job
        Remove-Job -Job $job
        return $false
    }
}

# ========================
# 监控进程并设置高优先级
# ========================
$operationCompleted = Invoke-WithTimeout -TimeoutSeconds $WaitTimeoutSeconds -ScriptBlock {
    while (-not (Get-Process -Name $using:TargetProcessName -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 5
    }

    Get-Process -Name $using:TargetProcessName | ForEach-Object {
        $_.PriorityClass = "High"
    }
} -ArgumentList $TargetProcessName

# 提示用户操作结果
if ($operationCompleted) {
    Show-UserMessage -Title "提示" -Message "✅ Voicemeeter 已启动并成功设置为高优先级！"
}
else {
    Show-UserMessage -Title "提示" -Message "⏰ 在 $WaitTimeoutSeconds 秒内未检测到 Voicemeeter 进程。" -Icon Warning
}

# 最终再次尝试设置优先级（避免错过首次启动）
Get-Process -Name $TargetProcessName -ErrorAction SilentlyContinue | ForEach-Object {
    $_.PriorityClass = "High"
}