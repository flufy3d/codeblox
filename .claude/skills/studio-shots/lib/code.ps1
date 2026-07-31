# ══ 脚本编辑器 / 输出面板 / 真试玩 ══════════════════════════════
#
# 单元 3 起课程开始写代码，多了三类图：代码长什么样、Output 里那行字、红字报错。
# 前两类没法用视口那套枢轴法，靠的是：命令栏写 Script.Source → 点文档标签 → 裁区域。
#
# 「Output 里那行字」**必须真按 F5 进 Play 模式**才忠实：
#   - 命令栏 print 出来的行尾是「- 编辑」，还会多一行 `> print(...)` 回显，孩子屏幕上不长这样
#   - Play 模式里脚本自己 print 出来是「- 服务器 - Script:2」，跟孩子看到的一模一样
# 视口类仍然不能用 Play 模式（相机归客户端管，见 rig.ps1 顶部），但**只裁输出面板
# 不受影响** —— 面板位置在 Play 模式下不动。

$script:CBX = @{
  DocTabX2 = 511; DocTabY2 = 152        # 第二个文档标签（脚本编辑器）
  CodeX = 367;  CodeY = 166              # 代码区左上角（跟 3D 视口同一块地方）
  CodeLineH = 15.5                       # 代码行距（实测）
  OutX = 0; OutY = 788; OutW = 1000; OutH = 172   # 输出面板：标题栏 + 筛选行 + 消息区
}

# 往一个 Script 里写代码。$Lines 是一行行源码。
#
# ⚠️ 两个坑，都踩过：
#  1) 别写 s.Source="第一行\n第二行"。源码里本来就有双引号（print("x")、
#     BrickColor.new("Bright red")），会把外层字符串提前闭合，报
#     `Expected identifier when parsing expression, got Unicode character U+4f60`
#     （U+4F60 是「你」—— 因为紧跟在被闭合的引号后面）。
#     正解：每行用 Lua 长括号 [[...]] 包起来，再 table.concat(...,"\n")。
#  2) 文档已经在编辑器里打开时，写 Source **不生效**（打开的 ScriptDocument
#     占着缓冲区，画面上还是旧代码，也不报错）。所以先 CloseAsync 再写。
function Set-Code([string]$ScriptPath, [string[]]$Lines, [switch]$Open) {
  $items = ($Lines | ForEach-Object { "[[" + $_ + "]]" }) -join ","
  $lua = "local SE=game:GetService(`"ScriptEditorService`") local s=$ScriptPath " +
         "local d=SE:FindScriptDocument(s) if d then d:CloseAsync() end " +
         "s.Source=table.concat({$items},`"\n`") "
  if ($Open) { $lua += "SE:OpenScriptDocumentAsync(s) " }
  $lua += "print(`"CODE SET`",#s.Source)"
  RunLua $lua 2600
}

# 裁脚本编辑器的代码区。$Rows = 要露出几行（会留一点余量），$W = 宽度。
# 从 x=367 起裁，行号那一栏也进画面 —— 讲「红字说第几行」时用得上。
function ShotCode([string]$OutName, [int]$Rows = 4, [int]$W = 620) {
  Focus-Win | Out-Null
  Click $script:CBX.DocTabX2 $script:CBX.DocTabY2 800    # 点脚本编辑器的文档标签
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 450
  Shot "_full_$OutName" | Out-Null
  $h = 10 + [int]($Rows * $script:CBX.CodeLineH)
  Crop "_full_$OutName" $OutName $script:CBX.CodeX $script:CBX.CodeY $W $h
}

# 裁输出面板（不进 Play 模式，拍空面板或已有内容时用）
function ShotOut([string]$OutName, [int]$H = 0) {
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 300
  Shot "_full_$OutName" | Out-Null
  $hh = if ($H -gt 0) { $H } else { $script:CBX.OutH }
  Crop "_full_$OutName" $OutName $script:CBX.OutX $script:CBX.OutY $script:CBX.OutW $hh
}

# 清空输出面板。LogService:ClearOutput() 在命令栏可用，而且**连命令自己的回显
# 一起清掉**（回显是提交时写进去的，晚于它就被清了）—— 所以想要一块干净的
# 输出面板，把 ClearOutput() 放在同一条命令的最后。
function Clear-Out { RunLua 'game:GetService("LogService"):ClearOutput()' 700 }

# 真进 Play 模式，等脚本跑完，裁输出面板，再停掉。
#   $WaitSec  进游戏到脚本 print 出来大概 8~10 秒（要加载角色）
function Play-ShotOut([string]$OutName, [int]$WaitSec = 9, [int]$H = 0) {
  Clear-Out | Out-Null
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 600     # 焦点移出命令栏，F5 才收得到
  Send "{F5}" 1500
  Start-Sleep -Seconds $WaitSec
  $p = ShotOut $OutName $H
  Focus-Win | Out-Null
  Send "+{F5}" 4000                                     # Shift+F5 停止
  Start-Sleep -Seconds 3
  $p
}
