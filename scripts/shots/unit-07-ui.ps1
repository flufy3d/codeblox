# ══ 单元 7 的代码 / 输出 / 资源管理器 / 试玩界面截图 ════════════
# 视口类在 unit-07.ps1（一张表批量跑）；这里 14 张每张步骤都不一样，一张一个函数。
# 样板是 unit-06-ui.ps1，坐标全是本机 1920x1080 实测。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-07.ps1"      # 要用它的 Hide-Baseplate / Reset-Spawn / $U7*
#   . "scripts\shots\unit-07-ui.ps1"
#   U7-All            # 按剧情顺序全拍一遍
#   U7-InsertDlg      # 或者单张重拍
#
# ⚠️ 全程 **Baseplate 处于藏起来的状态**（unit-07.ps1 的 Hide-Baseplate）。
#    资源管理器类的三张图（7.2-s1 / 7.7-s1 / 7.7-s3）拍的就是「7.1 里刚把
#    Baseplate 删掉」之后的树 —— 树上留着 Baseplate 就跟课文对不上了。
#    Play 类的图不需要地面：小人出生在 SpawnLocation 上，那块板是 Anchored 的。
#
# ⚠️ 这个单元的检查点是 **SpawnLocation 而不是普通 Part**（实机验证：
#    `player.RespawnLocation = 普通Part` 直接报 `Expected SpawnLocation got Part`），
#    而且必须 `Enabled = true` 才生效（禁用的赋值成功、重生却回默认出生点）。
#    课文 7.3 已按这个重写。下面 $U7CP 那段代码跟课文一字对应，改一边就要改另一边。

# ── 资源管理器行位（本机实测，行高 20）─────────────────────────
# 裁剪区从屏幕 y=145 起。Workspace 在 205，它每个孩子往下 20。
# ⚠️ 排序**不是**创建顺序也不是纯字母序：Camera / Terrain 钉在最前，
#    再按**类**分组（SpawnLocation 一组、Part 一组），组内才按字母。
#    每次改完树的内容都要先 ShotRegion 看一眼真实行位，别照抄。
$U7ROW0 = 205      # Workspace
function ExpRow([int]$N) { $U7ROW0 + 20 * $N }        # Workspace 的第 N 个孩子（1 起）
function ExpBoxY([int]$ScreenY) { $ScreenY - 145 - 11 }   # 屏幕 y → explorer 裁剪图内红框 y

# 代码区几何（跟单元 5/6 同一套公式，本机实测）
function CodeRow([int]$N) { [int](($N - 1) * 15.5 + 4) }
function CodeRows([int]$N) { [int]($N * 15.5) }
function CodeWidth([int]$Cols) { [math]::Max(360, [int](57 + $Cols * 8.08 + 20)) }
function BoxW([int]$Cols) { [int](57 + $Cols * 8.08 + 10 - 28) }

# 输出面板 / 视口 / 计分板的裁剪矩形（$U7LB 跟单元 6 同一个框，两个单元的
# 计分板图才是一套的）
$U7OUT = @{ X = 0; Y = 788; W = 1000; H = 100 }
$U7VP  = @{ X = 367; Y = 167; W = 1086; H = 612 }
$U7LB  = @{ X = 1053; Y = 180; W = 400; H = 160 }

# ── 公共动作 ─────────────────────────────────────────────────

function U7-CloseDocs {
  RunLua 'local SE=game:GetService("ScriptEditorService") for _,d in ipairs(SE:GetScriptDocuments()) do if not d:IsCommandBar() then d:CloseAsync() end end print("docs closed")' 1200
}

# 把 Workspace 和 ServerScriptService 里的脚本全删干净。
# 输出类截图的前置动作：Play 会跑**所有**脚本，多留一个就在输出里多一行。
function U7-NoScripts {
  RunLua 'local SSS=game:GetService("ServerScriptService") for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end for _,v in ipairs(SSS:GetChildren()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end print("no scripts")' 1400
}

# 真的 SpawnLocation 掉了就补一个回来。
#
# ⚠️ 这个坑很隐蔽：Build-Demo 每次开头的 CB_CLEAR 是**按名字**清场的
#    （名字记在 Workspace 的 CBX 属性里）。7.7-s1 要拍「一堆默认名」，其中
#    就有一个叫 SpawnLocation 的假货 —— 一旦把这个名字登记进 CBX，下一次
#    Build-Demo 会把**真的那块 SpawnLocation 也一起删掉**，于是 7.7-s3 的树上
#    没有 Spawn 那行、7.9-s2 的小人直接掉进虚空。
#    现在的约定：**永远不把 SpawnLocation / Spawn 登记进 CBX**，假货自己手动删；
#    需要真货的函数（U7-SpawnTree / U7-TidyTree / U7-HeroPlay）开头先叫一次这个。
function Ensure-Spawn {
  RunLua 'local ws=workspace local sp=ws:FindFirstChild("SpawnLocation") or ws:FindFirstChild("Spawn") if not sp then sp=Instance.new("SpawnLocation") sp.Parent=ws end sp.Name="SpawnLocation" sp.Anchored=true sp.Size=Vector3.new(12,1,12) sp.CFrame=CFrame.new(0,0.5,0) sp.Color=Color3.fromRGB(163,162,165) sp.Enabled=true print("spawn ensured")' 1100
}

function U7-HideChat {
  RunLua 'game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false) print("chat hidden")' 1500
}

# 把小人搬到某个部件正上方（Play 模式里跑，客户端语境）。抬 5 studs 让它落下去。
# $Delay 是故意的：先清输出面板，再让人落地，落地那一波 Touched 才完整留在面板里。
function U7-StandOn([string]$PartName, [double]$Delay = 3) {
  RunLua "local pl=game:GetService(`"Players`").LocalPlayer local c=pl.Character local t=workspace:FindFirstChild(`"$PartName`",true) if c and t then task.delay($Delay,function() c:PivotTo(CFrame.new(t.Position+Vector3.new(0,5,0))) end) end print(`"stand on $PartName after $Delay s`")" 1500
}

# 跟 unit-06-ui.ps1 的同名函数一样：进 Play → 关聊天 →（可选）搬人 → 等 → 裁一块矩形 → 停
function Play-Stand([string]$OutName, $R, [string]$StandOn = '', [int]$LoadSec = 12,
                    [int]$DwellSec = 0, [switch]$CleanLog, [string]$MidLua = '') {
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 600
  Send "{F5}" 1500
  Start-Sleep -Seconds $LoadSec
  U7-HideChat | Out-Null
  if ($MidLua) { RunLua $MidLua 1500 | Out-Null }
  elseif ($StandOn) { U7-StandOn $StandOn | Out-Null }
  if ($CleanLog) { Clear-Out | Out-Null }
  Start-Sleep -Seconds $DwellSec
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 500
  Shot "_full_$OutName" | Out-Null
  Crop "_full_$OutName" $OutName $R.X $R.Y $R.W $R.H | Out-Null
  Focus-Win | Out-Null
  Send "+{F5}" 4000
  Start-Sleep -Seconds 3
}

# ── 课文里的四段代码（跟 mdx 里的代码块一字对应）────────────────
# ⚠️ mdx 用 tab 缩进，这里用 4 空格 —— 编辑器里渲染出来一样宽，但空格的列数
#    是可算的，CodeWidth / BoxW 才靠得住（单元 3 起一直是这个约定）。

$U7CP = @(
  'local checkpoint = script.Parent'
  'checkpoint.Enabled = false   -- 先关着，不然会随机出生在这儿'
  ''
  'checkpoint.Touched:Connect(function(hit)'
  '    local player = game.Players:GetPlayerFromCharacter(hit.Parent)'
  '    if player then'
  '        checkpoint.Enabled = true   -- 碰到了，正式启用'
  '        player.RespawnLocation = checkpoint   -- 下次从这儿重来'
  '        print(player.Name .. " 到达检查点！")'
  '    end'
  'end)'
)

$U7GATE = @(
  'local block = script.Parent'
  'local startPos = block.Position'
  ''
  'while true do'
  '    block.Position = startPos + Vector3.new(0, 12, 0)'
  '    task.wait(1)'
  '    block.Position = startPos'
  '    task.wait(1)'
  'end'
)

$U7LAVACODE = @(
  'local lava = script.Parent'
  ''
  'local function onTouch(hit)'
  '    local humanoid = hit.Parent:FindFirstChild("Humanoid")'
  '    if humanoid then'
  '        humanoid.Health = 0'
  '    end'
  'end'
  ''
  'lava.Touched:Connect(onTouch)'
)

$U7PAD = @(
  'local pad = script.Parent'
  'local arch = workspace.FinishArch   -- 你的终点拱门，名字要和这里一致'
  'local debounce = false'
  ''
  'pad.Touched:Connect(function(hit)'
  '    local player = game.Players:GetPlayerFromCharacter(hit.Parent)'
  '    if player and not debounce then'
  '        debounce = true'
  '        player.leaderstats.Wins.Value += 1'
  '        print("你赢了！")'
  '        arch.Material = Enum.Material.Neon'
  '        arch.Color = Color3.fromRGB(255, 215, 0)   -- 金色'
  '        task.wait(2)'
  '        debounce = false'
  '    end'
  'end)'
)

# 7.6 第一段：记 Wins 的计分板（放 ServerScriptService）。不拍它的代码图
# （跟单元 6 的 6.4-s1 几乎一样），但输出/计分板类的图都要靠它先发分数。
$U7WINS = @(
  'local Players = game:GetService("Players")'
  ''
  'Players.PlayerAdded:Connect(function(player)'
  '    local leaderstats = Instance.new("Folder")'
  '    leaderstats.Name = "leaderstats"'
  '    leaderstats.Parent = player'
  ''
  '    local wins = Instance.new("IntValue")'
  '    wins.Name = "Wins"'
  '    wins.Value = 0'
  '    wins.Parent = leaderstats'
  'end)'
)

# ── 7.2-s1 · 资源管理器里的 SpawnLocation ────────────────────
# 树：Workspace / Camera / Terrain / SpawnLocation —— Baseplate 已藏、Rig 已 Stash，
# 正好是孩子在 7.1 删完地板之后看到的样子。
# 选中子节点会让父节点自动展开（资源管理器没有「展开」的 API）。
function U7-SpawnTree {
  Clear-Scene | Out-Null
  Stash-Rig | Out-Null
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Ensure-Spawn | Out-Null
  RunLua 'game:GetService("Selection"):Set({workspace.SpawnLocation})' 1300 | Out-Null
  ShotRegion "_t21" "explorer" | Out-Null
  # 裁到屏幕 y=315 = Lighting 那行的下边界（行高 20，中心 305）。切在行边界上，
  # 底下才不会露出半行字。
  ReCrop "_t21" "_t21c" 0 145 362 170 | Out-Null
  Annotate "_t21c" "v_7_2-s1" @( @{ t='box'; x=3; y=(ExpBoxY (ExpRow 3)); w=355; h=22 } ) 2
}

# ── 7.3-s1 · 「插入对象」窗口里搜 SpawnLocation ───────────────
#
# ⚠️ 右键 → 悬停子菜单 → 点下去 → 打字 → 截图 **必须写在同一个函数里**：
#    下一次工具调用开头的 Focus-Win 会让弹出层失焦、自动收起。
# ⚠️ 右键 Workspace 的 x 要靠左压在文字上（58 稳）。行名右边悬停会冒出一个
#    圆形「＋」快捷插入按钮，正好点在它上面时菜单根本不弹，而且完全不报错。
# ⚠️ 搜索框里的字走剪贴板 + Ctrl+V，别用 SendKeys：中文输入法会吃掉空格、乱改大小写。
#
# Workspace 右键菜单：Copy As 217 / 重命名 248 / 插入 269 / 层次结构 292 / …
# 「插入」的子菜单：插入部件 270 / 插入对象… 292 / 导入 Roblox 模型 314（x 范围 240~395）
function U7-InsertDlg {
  Focus-Win | Out-Null
  RClick 58 $U7ROW0 1200
  Move-To 120 269; Start-Sleep -Milliseconds 900     # 悬停「插入」
  Move-To 180 269; Start-Sleep -Milliseconds 900     # 往右挪，子菜单弹出来
  Click 280 292 1800                                  # 点「插入对象…」
  Set-Clipboard -Value "SpawnLocation"
  Send "^v" 1400
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 800
  Shot "_full_ins" | Out-Null
  Send "{ESC}" 600
  # 带上左边的资源管理器一起裁：单裁那个小窗口只有 245 宽，网页上要拉到 2.9 倍
  # 就糊了；530 宽只拉 1.3 倍，还顺带说清「这是右键 Workspace 之后弹出来的」。
  Crop "_full_ins" "_ins" 0 195 530 155 | Out-Null
  Annotate "_ins" "v_7_3-s1" @( @{ t='box'; x=288; y=118; w=228; h=22 } ) 2
}

# ── 代码图 4 张 ──────────────────────────────────────────────
# 每张都先建好宿主部件、把代码写进去、打开文档标签再裁。
# 换宿主前必须 U7-CloseDocs：ShotCode 点的是**第二个**文档标签，
# 两个脚本都开着的话点到的是先打开的那个。

# 7.3-s3 · 检查点代码（11 行），红框框住 Enabled=true + RespawnLocation 两行
function U7-CpCode {
  U7-CloseDocs | Out-Null
  Build-Demo 'local c=Instance.new("SpawnLocation") c.Name="Checkpoint1" c.Anchored=true c.Size=Vector3.new(8,1,8) c.CFrame=base(Vector3.new(0,0.5,0)) c.Color=Color3.fromRGB(45,130,225) c.Parent=ws ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|").."Checkpoint1|") local s=Instance.new("Script") s.Name="Script" s.Parent=c' | Out-Null
  Set-Code 'workspace.Checkpoint1.Script' $U7CP -Open
  ShotCode "_cpc" 12 (CodeWidth 64) | Out-Null
  Annotate "_cpc" "v_7_3-s3" @( @{ t='box'; x=28; y=(CodeRow 7); w=(BoxW 64); h=(CodeRows 2) } ) 2
}

# 7.4-s2 · 升降闸门代码（9 行），红框框住 while true do 到 end 整段循环体
function U7-GateCode {
  U7-CloseDocs | Out-Null
  Build-Demo 'local p=PN("MovingBlock",Vector3.new(2,10,9),Vector3.new(0,6,0),M.Plastic,Color3.fromRGB(226,124,36)) local s=Instance.new("Script") s.Name="Script" s.Parent=p' | Out-Null
  Set-Code 'workspace.MovingBlock.Script' $U7GATE -Open
  ShotCode "_gc" 10 (CodeWidth 52) | Out-Null
  Annotate "_gc" "v_7_4-s2" @( @{ t='box'; x=28; y=(CodeRow 4); w=(BoxW 52); h=(CodeRows 6) } ) 2
}

# 7.5-s2 · 熔岩判定代码（10 行），红框框住 humanoid.Health = 0
function U7-LavaCode {
  U7-CloseDocs | Out-Null
  Build-Demo 'local p=PN("Lava1",Vector3.new(8,1,8),Vector3.new(0,0.5,0),M.Neon,Color3.fromRGB(200,30,20)) local s=Instance.new("Script") s.Name="Script" s.Parent=p' | Out-Null
  Set-Code 'workspace.Lava1.Script' $U7LAVACODE -Open
  ShotCode "_lc" 11 (CodeWidth 57) | Out-Null
  Annotate "_lc" "v_7_5-s2" @( @{ t='box'; x=28; y=(CodeRow 6); w=(BoxW 57); h=(CodeRows 1) } ) 2
}

# 7.6-s2 · 终点垫代码（16 行），红框框住 arch.Material + arch.Color 两行
function U7-PadCode {
  U7-CloseDocs | Out-Null
  Build-Demo 'local p=PN("FinishPad",Vector3.new(6,1,6),Vector3.new(0,0.5,0),M.Plastic,Color3.fromRGB(238,238,242)) local s=Instance.new("Script") s.Name="Script" s.Parent=p local a=PN("FinishArch",Vector3.new(11,1.5,1.5),Vector3.new(0,11.75,0),M.Plastic,Color3.fromRGB(128,127,131))' | Out-Null
  Set-Code 'workspace.FinishPad.Script' $U7PAD -Open
  ShotCode "_pc" 17 (CodeWidth 69) | Out-Null
  Annotate "_pc" "v_7_6-s2" @( @{ t='box'; x=28; y=(CodeRow 11); w=(BoxW 69); h=(CodeRows 2) } ) 2
}

# ── 7.3-s4 · 输出面板「到达检查点」──────────────────────────
# 场景里只留检查点这一个脚本，Play 之后把小人搬上去踩一脚。
# ⚠️ 一脚踩下去 Touched 会触发好几次（脚/腿/身子各算一次），输出面板把连续
#    重复的消息合并成一行、后面记 (xN)。这个数每次跑都不一样，课文里没写死。
function U7-CpOut {
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Build-Demo 'local c=Instance.new("SpawnLocation") c.Name="Checkpoint1" c.Anchored=true c.Size=Vector3.new(8,1,8) c.CFrame=base(Vector3.new(0,0.5,0)) c.Color=Color3.fromRGB(45,130,225) c.Parent=ws ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|").."Checkpoint1|") local s=Instance.new("Script") s.Name="Script" s.Parent=c' | Out-Null
  Set-Code 'workspace.Checkpoint1.Script' $U7CP
  Play-Stand "_o73" $U7OUT "Checkpoint1" 12 8 -CleanLog
  Annotate "_o73" "v_7_3-s4" @( @{ t='box'; x=6; y=56; w=460; h=21 } ) 2
}

# ── 7.8-s1 · 红字报错 FinishArch is not a valid member of Workspace ──
# 终点垫脚本第 2 行 `local arch = workspace.FinishArch` 一进 Play 就跑，
# **不用踩垫子**就报错 —— 所以这张不需要搬小人。
# 故意**不建** FinishArch，正是课文 7.7 警告的「改了名字/打进组里」的后果。
function U7-ErrOut {
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Build-Demo 'local p=PN("FinishPad",Vector3.new(6,1,6),Vector3.new(0,0.5,0),M.Plastic,Color3.fromRGB(238,238,242)) local s=Instance.new("Script") s.Name="Script" s.Parent=p' | Out-Null
  Set-Code 'workspace.FinishPad.Script' $U7PAD
  # H=126 而不是别处那个 100：报错底下还跟着 Stack Begin / Script Line 2 / Stack End
  # 三行，课文讲的就是「按哪一行去修」。行距 17px，56（标题栏+筛选行）+ 17×4 = 124，
  # 给 126 正好切在第 4 行的下边界上；给 100 会把第 3 行拦腰截断。
  Play-ShotOut "_o81" 10 126 | Out-Null
  Annotate "_o81" "v_7_8-s1" @( @{ t='box'; x=6; y=56; w=620; h=21 } ) 2
}

# ── 通关那一组（7.8-s2 输出 / 7.6-s4 计分板）──────────────────
# 三样都要齐：SSS 里的 Wins 计分板、workspace.FinishArch、装了脚本的终点垫。
function U7-WinScene {
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Build-Demo 'local p=PN("FinishPad",Vector3.new(6,1,6),Vector3.new(0,0.5,0),M.Plastic,Color3.fromRGB(238,238,242)) local s=Instance.new("Script") s.Name="Script" s.Parent=p local a=PN("FinishArch",Vector3.new(11,1.5,1.5),Vector3.new(0,11.75,0),M.Plastic,Color3.fromRGB(128,127,131))' | Out-Null
  RunLua 'local s=Instance.new("Script") s.Name="Wins" s.Parent=game:GetService("ServerScriptService") print("wins script")' 1200 | Out-Null
  Set-Code 'game:GetService("ServerScriptService").Wins' $U7WINS
  Set-Code 'workspace.FinishPad.Script' $U7PAD
}

# 「冲过终点垫」：落到垫子上，待 1.2 秒，再回起点。
#
# ⚠️ 别用「站着不动」那一套（U7-StandOn）。人一直站在垫子上时，debounce 的
#    task.wait(2) 一解锁，落地余震又触发一次 Touched，面板上就变成
#    「你赢了！(x2)」，跟课文讲的「冲一次线只记一次」对着干。
#    靠调 DwellSec 去卡那个窗口是徒劳的：实测 5 → (x2)、3 → 空面板、4 → 又是
#    (x2)，人落没落稳本身就带随机性。改成**踩一下就走**，只可能触发一波，
#    debounce 把它收成一行，拍几次都一样。这也更贴课文说的「冲过终点垫」。
#
# ⚠️ 清输出面板要**并进这条命令的末尾**，别用 Play-Stand 的 -CleanLog 走单独一条
#    命令：实测那样拍出来面板是空的（计分板却好好地记着 Wins=1，说明脚本明明
#    跑了）—— 多一次命令栏交互就多一次不确定。ClearOutput() 连本条命令自己的
#    回显一起清掉（回显早于它写入），而小人是 task.delay(3) 才落地的，
#    所以清完之后打的那行「你赢了！」稳稳留在面板上。
$U7DASH = 'local pl=game:GetService("Players").LocalPlayer local c=pl.Character ' +
          'local pad=workspace:FindFirstChild("FinishPad") local sp=workspace:FindFirstChild("SpawnLocation") ' +
          'if c and pad and sp then task.delay(3,function() ' +
          'c:PivotTo(CFrame.new(pad.Position+Vector3.new(0,5,0))) task.wait(1.2) ' +
          'c:PivotTo(CFrame.new(sp.Position+Vector3.new(0,5,0))) end) end ' +
          'game:GetService("LogService"):ClearOutput()'

# 7.8-s2 · 改好之后重新试玩：只有一行「你赢了！」，没有红字
function U7-WinOut {
  U7-WinScene
  Play-Stand "_o82" $U7OUT -LoadSec 12 -DwellSec 8 -MidLua $U7DASH
  Annotate "_o82" "v_7_8-s2" @( @{ t='box'; x=6; y=56; w=300; h=21 } ) 2
}

# 7.6-s4 · 试玩画面右上角的计分板，Wins 那一列是 1
# ⚠️ 计分板默认收起，要在游戏里点左上角 ☰ → 排行榜才出现 —— 但**开过一次就
#    一直记着**（单元 6 拍 6.4-s2 时已经开过），后面每次 F5 都自己出现。
#    万一这张拍出来右上角是空的，就照 unit-06-ui.ps1 的 U6-Leaderboard0 点一次。
function U7-WinBoard {
  U7-WinScene
  # 跟 7.8-s2 同一个「冲过去再离开」的动作，Wins 才稳定停在 1（站着不动会变 2）
  Play-Stand "_lb76" $U7LB -LoadSec 12 -DwellSec 8 -MidLua $U7DASH
  Annotate "_lb76" "v_7_6-s4" @( @{ t='box'; x=300; y=94; w=92; h=30 } ) 3
}

# ── 7.7 整理与命名：整理前 / 右键菜单 / 整理后 ────────────────

# 7.7-s1 · 乱糟糟的树：一堆默认名 Part + 两个 SpawnLocation
# ⚠️ 资源管理器按**类**分组，所以顺序是 Camera / Terrain / SpawnLocation ×2 /
#    Part ×6，不是插入顺序。课文的 capture 说明按这个实际顺序写。
function U7-MessyTree {
  Stash-Rig | Out-Null
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Ensure-Spawn | Out-Null
  # 第二块 SpawnLocation 叫 CB_extraSpawn（CB_ 前缀会被清场自动收走），
  # 但树上要显示默认名，所以建完再改名 —— **不登记进 CBX**，见 Ensure-Spawn 的说明。
  Build-Demo 'for i=1,6 do PN("Part",Vector3.new(8,1,8),Vector3.new(i*10-30,0.5,0)) end local c=Instance.new("SpawnLocation") c.Name="SpawnLocation" c.Anchored=true c.Size=Vector3.new(8,1,8) c.CFrame=base(Vector3.new(20,0.5,0)) c.Enabled=false c.Parent=ws' | Out-Null
  RunLua 'game:GetService("Selection"):Set({})' 1000 | Out-Null
  ShotRegion "_t71" "explorer" | Out-Null
  # Workspace + 10 个孩子，最后一个在屏幕 y=405，裁到 430 才把它整行收进来
  ReCrop "_t71" "v_7_7-s1" 0 145 362 285 | Out-Null
  # 假货自己删（它不在 CBX 里，清场不会管它）—— 留着的话后面每张树图都多一行
  RunLua 'local ws=workspace for _,v in ipairs(ws:GetChildren()) do if v:IsA("SpawnLocation") and v.Size.X==8 then v:Destroy() end end print("extra spawn removed")' 1100 | Out-Null
}

# 7.7-s2 · 多选两个检查点 → 右键 → 红框框住「作为模型分组」
#
# ⚠️ 右键菜单的项数**随选中几个而变**：多选时没有「重命名」，它后面所有项
#    整体上移一行（22px）。这里量的是**多选**那一套：
#    剪切 277 / 复制 300 / Copy As 322 / 重复 351 / 删除 373 /
#    作为模型分组 403 / 作为文件夹分组 426 / 实体建模 448 / 插入 470 / …
#    拿单选量出来的坐标去点多选菜单会点到隔壁那项。
# ⚠️ 右键 → 截图必须一次调用内做完（弹出层会被下一次 Focus-Win 收掉）。
function U7-GroupMenu {
  Stash-Rig | Out-Null
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Build-Demo 'local function cp(n,x) local c=Instance.new("SpawnLocation") c.Name=n c.Anchored=true c.Size=Vector3.new(8,1,8) c.CFrame=base(Vector3.new(x,0.5,0)) c.Color=Color3.fromRGB(45,130,225) c.Enabled=false c.Parent=ws ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|")..n.."|") return c end local a=cp("Checkpoint1",10) local b=cp("Checkpoint2",0) PN("Lava1",Vector3.new(8,1,8),Vector3.new(-10,0.5,0),M.Neon,Color3.fromRGB(200,30,20)) PN("MovingBlock",Vector3.new(2,10,9),Vector3.new(-20,6,0),M.Plastic,Color3.fromRGB(226,124,36)) S:Set({a,b})' | Out-Null
  Focus-Win | Out-Null
  RClick 70 (ExpRow 3) 1400          # Checkpoint1 那一行（Camera / Terrain 之后第 1 个）
  Move-To 500 800
  Start-Sleep -Milliseconds 700
  Shot "_full_grp" | Out-Null
  Send "{ESC}" 600
  # 从 250 起裁：258 会把最上面那两行选中的检查点切成半截
  Crop "_full_grp" "_grp" 20 250 340 205 | Out-Null
  Annotate "_grp" "v_7_7-s2" @( @{ t='box'; x=68; y=142; w=160; h=22 } ) 2
}

# 7.7-s3 · 整理后的树：名字都清楚了，同类收进 Model，其中一个展开着露出 Script
# 选中 Script 会让它上面两级（Model → 那块 Part）自动展开。
function U7-TidyTree {
  Stash-Rig | Out-Null
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Ensure-Spawn | Out-Null
  Build-Demo 'local sp=ws:FindFirstChild("SpawnLocation") if sp then sp.Name="Spawn" sp.CFrame=base(Vector3.new(20,0.5,0)) sp.Color=Color3.fromRGB(75,200,90) end
local function grp(name,items) local m=Instance.new("Model") m.Name=name m.Parent=ws for _,v in ipairs(items) do v.Parent=m end ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|")..name.."|") return m end
local function cp(n,x) local c=Instance.new("SpawnLocation") c.Name=n c.Anchored=true c.Size=Vector3.new(8,1,8) c.CFrame=base(Vector3.new(x,0.5,0)) c.Color=Color3.fromRGB(45,130,225) c.Enabled=false c.Parent=ws return c end
grp("Checkpoints",{cp("Checkpoint1",10),cp("Checkpoint2",4)})
grp("Lavas",{PN("Lava1",Vector3.new(8,1,8),Vector3.new(-6,0.5,0),M.Neon,Color3.fromRGB(200,30,20)),PN("Lava2",Vector3.new(8,1,8),Vector3.new(-14,0.5,0),M.Neon,Color3.fromRGB(200,30,20))})
local mb=PN("MovingBlock",Vector3.new(2,10,9),Vector3.new(-2,6,0),M.Plastic,Color3.fromRGB(226,124,36))
local s=Instance.new("Script") s.Name="Script" s.Parent=mb
PN("FinishPad",Vector3.new(6,1,6),Vector3.new(-22,0.5,0),M.Plastic,Color3.fromRGB(238,238,242))
PN("FinishArch",Vector3.new(11,1.5,1.5),Vector3.new(-22,11.75,0),M.Neon,Color3.fromRGB(255,215,0))
S:Set({s})' | Out-Null
  ShotRegion "_t73" "explorer" | Out-Null
  ReCrop "_t73" "v_7_7-s3" 0 145 362 285 | Out-Null
}

# ── 7.9-s2 · 试玩全景：站在自己搭的 Obby 上，右上角是计分板 ────
# 这张要的是「真正在玩的样子」，所以裁的是**整个视口**，不是那块牌子。
# 整条路照 unit-07.ps1 的 $U7FULL 建（同一份布局，成果图才跟前面几课对得上），
# 真的 SpawnLocation 也搬进起点 —— 小人就出生在路上。
# 进 Play 后把小人挪到闸门前那块台阶上、面朝终点，机位（在小人正后方）
# 正好顺着路往下看，一眼看完整条关卡。
function U7-HeroPlay {
  U7-CloseDocs | Out-Null
  U7-NoScripts | Out-Null
  Unstash-Rig | Out-Null
  Park-Rig | Out-Null
  Ensure-Spawn | Out-Null
  Build-Demo $U7FULL 'Vector3.new(0,3,0)' 194 22 | Out-Null
  RunLua 'local s=Instance.new("Script") s.Name="Wins" s.Parent=game:GetService("ServerScriptService")' 1200 | Out-Null
  Set-Code 'game:GetService("ServerScriptService").Wins' $U7WINS
  # 站在**起点**上、面朝终点方向（用起点和拱门两块真实部件算方向，不猜世界坐标）。
  # ⚠️ 别站在路中段：默认第三人称机位就在小人正后方约 10 studs，站在闸门跟前
  #    那块 10 高的橙方块会糊满大半个屏幕，后面的熔岩和金拱门全看不见（第一版
  #    站在 Checkpoint1 前 4 studs，拍出来就是一堵橙墙）。站在整条路的最前头，
  #    路才会顺着镜头往里递进，一张图看完全部机关。
  #
  # ⚠️ 光把小人转过去没用：Play 模式的相机**不会**跟着 PivotTo 的朝向转，它保持
  #    自己原来的方位，于是整条路歪在画面右边（第一版就是这样）。要自己接管：
  #    `cam.CameraType = Scriptable` 之后默认的相机脚本就不再每帧覆盖 CFrame 了，
  #    这时才能把机位摆到小人身后、顺着路往里看。
  #    （编辑模式那套「写 CFrame 只有位置生效」的怪毛病在 Play 模式不存在。）
  # ⚠️ 机位还要**偏到路的侧上方**，别正对着路轴。正对时一条直线的关卡整条叠在
  #    一起：闸门把它后面的熔岩和金拱门全挡住，只看得到最前面两块（踩过一次）。
  #    偏 8 studs 到侧面、抬到 9 高，各个机关才在画面里横着铺开。
  # ⚠️ lookAt 的目标别放太远：瞄 p+dir*26 时相机几乎平视，画面上半幅全是空天，
  #    小人还被挤到左下角切掉半个。瞄 p+dir*14 相机下俯约 30°，地平线压到顶边，
  #    整条路才填满画面。
  $pose = 'local pl=game:GetService("Players").LocalPlayer local c=pl.Character ' +
          'local cam=workspace.CurrentCamera ' +
          'local sp=workspace:FindFirstChild("SpawnLocation") local fa=workspace:FindFirstChild("FinishArch") ' +
          'if c and sp and fa then local dir=(fa.Position-sp.Position).Unit ' +
          'local p=sp.Position+dir*2+Vector3.new(0,5,0) ' +
          'task.delay(2,function() c:PivotTo(CFrame.lookAt(p,p+dir)) task.wait(0.8) ' +
          'cam.CameraType=Enum.CameraType.Scriptable ' +
          'local right=dir:Cross(Vector3.new(0,1,0)).Unit ' +
          'local eye=p-dir*11+right*8+Vector3.new(0,9,0) ' +
          'cam.CFrame=CFrame.lookAt(eye,p+dir*14) end) end print("posed")'
  Play-Stand "v_7_9-s2" $U7VP -LoadSec 12 -DwellSec 8 -MidLua $pose
}

# ── 全部 ─────────────────────────────────────────────────────
# 顺序有两条硬约束：
#  · 资源管理器类（7.2-s1 / 7.7-s1 / 7.7-s2 / 7.7-s3）要求 Rig 已 Stash ——
#    孩子的树里没有 Rig 这个节点，露出来图就对不上。7.9-s2 才 Unstash。
#  · 输出类每张拍的都是**上一次 Set-Code 写进去的那段代码**跑出来的结果，
#    而且场景里不能留别的脚本（Play 会跑所有脚本，多一个就多一行）。
function U7-All {
  U7-SpawnTree                                    # 7.2
  U7-InsertDlg; U7-CpCode; U7-CpOut               # 7.3
  U7-GateCode                                     # 7.4
  U7-LavaCode                                     # 7.5
  U7-PadCode; U7-WinBoard                         # 7.6
  U7-MessyTree; U7-GroupMenu; U7-TidyTree         # 7.7
  U7-ErrOut; U7-WinOut                            # 7.8
  U7-HeroPlay                                     # 7.9
  "拍完 14 张。逐张 Read $script:SD\v_7_*.png 核对，再跑 npm run shots:save"
}
