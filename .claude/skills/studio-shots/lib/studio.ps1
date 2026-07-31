# ══ 驱动 Roblox Studio ══════════════════════════════════════════

# 在 Studio 命令栏执行一段 Lua。
# 关键点：
#  1) 走剪贴板粘贴，不逐字打字（中文输入法会吃空格）
#  2) 多行会被压成一行 —— Lua 语句之间用空格分隔即可，别依赖换行
#  3) 用「运行」按钮触发，不用 Ctrl+Enter（后者会偶发不生效）；
#     两个都发会导致命令执行两次
function RunLua([string]$Lua, [int]$Wait=900) {
  $one = ($Lua -split "`r?`n" | Where-Object { $_.Trim() -ne "" }) -join " "
  Set-Clipboard -Value $one
  Focus-Win "RobloxStudio*" | Out-Null
  Click $script:CBS.CmdBarX $script:CBS.CmdBarY
  Send "^a" 120
  Send "^v" 320
  Click $script:CBS.RunBtnX $script:CBS.RunBtnY $Wait
}

# 截 3D 视口（先把鼠标停到角落，别让光标进画面）
function ShotVP([string]$Name) {
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 250
  Shot "_full_$Name" | Out-Null
  Crop "_full_$Name" $Name $script:CBS.VpX $script:CBS.VpY $script:CBS.VpW $script:CBS.VpH
}

# 截输出面板（看 print 的结果 —— 目前只能靠 Read 图片人眼看）
function ShotLog([string]$Name = "_log") {
  Shot "_full_$Name" | Out-Null
  Crop "_full_$Name" $Name $script:CBS.LogX $script:CBS.LogY $script:CBS.LogW $script:CBS.LogH
}

# 截整个 Studio 窗口（属性面板 / 资源管理器类截图从这上面裁）
function ShotWin([string]$Name) {
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 250
  Shot $Name
}

# 把所有残留的相机保持循环踢掉（代数令牌抬到很高）
function Stop-CamHolds { RunLua 'workspace:SetAttribute("CBGEN",999999)' 700 }

# 清掉脚本建的所有部件 + 相机令牌，收工时用
function Clear-Scene {
  RunLua 'local ws=workspace game:GetService("Selection"):Set({}) for _,v in ipairs(ws:GetChildren()) do if v.Name:sub(1,3)=="CB_" then v:Destroy() end end ws:SetAttribute("CBGEN",nil) print("CB scene cleared")' 900
}
