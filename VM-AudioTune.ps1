# 设置编码防止乱码（确保中文提示正常显示）
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding = $OutputEncoding

# 设置窗口标题
$Host.UI.RawUI.WindowTitle = "VoiceMeeter Monitor"

# 目标进程名称（不带 .exe）
# 任务管理器 > 详细信息 > 找到进程 > 右键 > 属性 > 复制名称(去掉 .exe)
[string]$VoiceMeeterProcessName = "voicemeeterpro"
# windows音频设备进程名称（不带 .exe）
[string]$AudiodgProcessName = "audiodg"

# 等待超时时间（单位：分钟）
[int]$WaitTimeoutMinutes = 5
function Get-ProcessForce {
    param (
        [string]$Name
    )

    $time = 0

    $process = $null
    while ($null -eq $process) {
        $process = Get-Process -Name $Name -ErrorAction SilentlyContinue
        if ($null -eq $process) {
            $time += 5
            if ($time -ge $WaitTimeoutMinutes * 60) {
                Write-Error "获取进程超时($WaitTimeoutMinutes分钟)"
                exit
            }
            Start-Sleep -Seconds 5
        }
    }
    return $process
}

# 设置进程优先级
function Set-ProcessPriority {
    param (
        [string]$Name,
        [ValidateSet("High", "Normal", "Idle")]
        [string]$Priority
    )

    try {
        $process = Get-ProcessForce -Name $Name
        $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::$Priority
        Write-Host "设置进程($Name)优先级($Priority)成功"
    }
    catch {
        Write-Error "设置进程($Name)优先级($Priority)失败: $_"
    }
}

# 设置进程cpu隔离，从0开始
function Set-ProcessAffinity {
    param (
        [string] $Name,
        [int] $CpuCoreIndex
    )

    try {
        $process = Get-ProcessForce -Name $Name
        $affinityMask = 1 -shl $CpuCoreIndex
        $process.ProcessorAffinity = $affinityMask
        Write-Host "设置进程($Name)cpu核心($CpuCoreIndex)隔离成功"
    }
    catch {
        Write-Error "设置进程($Name)cpu核心($CpuCoreIndex)隔离失败: $_"
    }    
}


# 获取管理员权限
function Get-AdministratorPrivilege {
    # 需要管理员权限运行 
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
        exit 
    }
}

Get-AdministratorPrivilege

# 判断cpu核心数是否支持设置核心隔离
$cpuCoreCount = (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors
Write-Host  "cpu核心数: $cpuCoreCount"

# 设置进程优先级
Write-Host  "设置进程优先级为高"
Set-ProcessPriority -Name $VoiceMeeterProcessName -Priority High
Set-ProcessPriority -Name $AudiodgProcessName -Priority High

# 设置进程cpu核心隔离
if ($cpuCoreCount -ge 2) {
    Write-Host  "设置进程cpu核心隔离为1"
    Set-ProcessAffinity -Name $VoiceMeeterProcessName -CpuCoreIndex 1
    Set-ProcessAffinity -Name $AudiodgProcessName -CpuCoreIndex 1
}
else {
    Write-Host  "cpu核心数小于2,不设置核心隔离"
}

Pause