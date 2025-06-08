# 设置编码防止乱码（确保中文提示正常显示）
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding = $OutputEncoding

# 设置目标文件夹路径
$Dir = $PSScriptRoot
$Paths = @("VM-AudioTune.ps1", "VM-AudioTuneManager.ps1​")

# 显示消息框函数
function Show-UserMessage {
    param (
        [string]$Title = "提示",
        [string]$Message,
        [ValidateSet("Information", "Warning", "Error", "Question")]
        [string]$Icon = "Information"
    )
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, "OK", [System.Windows.Forms.MessageBoxIcon]::$Icon)
}

$Paths  | ForEach-Object { 
    $FilePath = Join-Path -Path $Dir -ChildPath $_

    # 读取内容
    $Content = Get-Content -Path $FilePath -Raw

    # 使用 UTF-8 with BOM 编码写回
    $Utf8WithBomEncoding = New-Object System.Text.UTF8Encoding $true
    [System.IO.File]::WriteAllText($FilePath, $Content, $Utf8WithBomEncoding)
    Show-UserMessage -Message "已添加 BOM 头：$FilePath"
}