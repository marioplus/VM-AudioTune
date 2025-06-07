# 🎤 Voicemeeter 高优先级设置工具

该项目包含两个 PowerShell 脚本，用于帮助你在启动 Voicemeeter 时自动将其进程优先级设为“高”，一定程度上缓解爆音问题。

## 📁 文件说明

| 文件名                           | 功能描述                                               |
| -------------------------------- | ------------------------------------------------------ |
| `VoiceMeeter-Monitor.ps1`        | 主监控脚本：检测 `voicemeeterpro.exe` 并设置为高优先级 |
| `VoiceMeeter-StartupManager.ps1` | 启动管理脚本：创建/删除开机自启快捷方式                |
| `Convert-ToUTF8BOM.ps1`          | 将上面的两个脚本hzuan码为UTF-8编码并添加UTF-8 BOM头    |

## 🧩 使用方法

### 1. 设置 VoiceMeeter 进程名称
 
> 打开任务管理器 > 切换到“详细信息”选项卡 > 找到 `voicemeeterpro.exe` 或类似进程 > 右键 > 属性 > 复制进程名称（**去掉 `.exe` 后缀**）。

1. 打开 `VoiceMeeter-Monitor.ps1`；
2. 找到以下行：
   ```powershell
   [string]$TargetProcessName = "voicemeeterpro"
3. 将 `voicemeeterpro` 替换为步骤 2 中复制的进程名称。
4. 保存文件。
5. 双击运行`Convert-ToUTF8BOM.ps1` 将脚本转化为 `UTF-8 with BOM` 编码格式（否则开机自启动脚本提示会乱码）。

### 2. 手动运行主脚本

双击运行 `VoiceMeeter-Monitor.ps1`，它会：

- 等待 Voicemeeter 启动；
- 成功检测后自动设置其进程为“高优先级”；
- 若未在 5 分钟内检测到目标进程，会弹出提示。

### 3. 添加开机启动项

运行 `VoiceMeeter-StartupManager.ps1`：

- 如果没有快捷方式 → 自动创建；
- 如果已有快捷方式 → 自动删除；
- 快捷方式会静默运行，不会弹出 PowerShell 窗口。
