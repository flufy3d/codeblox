# ══ 单元 6 的代码 / 输出 / 资源管理器 / 试玩界面截图 ════════════
# 视口类在 unit-06.ps1（一张表批量跑）；这里 18 张每张步骤都不一样，一张一个函数。
# 样板是 unit-05-ui.ps1，坐标全是本机 1920x1080 实测。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-06-ui.ps1"
#   U6-All            # 按剧情顺序全拍一遍
#   U6-DupMenu        # 或者单张重拍
#
# ⚠️ 这个单元多了一类前面都没有的图：**试玩画面里的计分板**。三件事必须先知道：
#
#  1) 计分板（leaderstats）出现在**游戏画面右上角**，不是左上角。课文原来全写错了，
#     已按实机改过。
#  2) 它**默认是收起的**。要在试玩中点画面左上角的 ☰ → 菜单里的「排行榜」才会出现。
#     好消息：**开过一次就记住了**，后面每次 F5 都自己出现，不用每张图都点一遍。
#     （6.4-s2 拍的就是这个菜单本身。）
#  3) 「用户」那一列是**登录账号的用户名**，Studio 里改不动
#     （`Player.Name` / `DisplayName` 都报 lacking capability WritePlayer）。
#     用户拍板：就用真名，不做任何遮盖，所有图 100% 原样。
#
# ⚠️ 这个单元有**两个脚本宿主**（6.1~6.4 在 ServerScriptService，6.5~6.8 在 Pad 里），
#    跟单元 4/5「从头到尾复用一个脚本」不一样。切换宿主前必须 U6-CloseDocs：
#    ShotCode 点的是**第二个**文档标签，两个脚本都开着的话点到的是上一个。

# ── 常量 ─────────────────────────────────────────────────────

$U6S   = 'game:GetService("ServerScriptService").Script'   # 计分板脚本（6.1~6.4）
$U6P   = 'workspace.Pad.Script'                            # 得分垫脚本（6.5~6.8）

# 计分板在视口右上角的裁剪框。400 宽是挑过的：牌子本身只有 242 宽，
# 单裁牌子网页上要拉到 2.9 倍（<Shot> 是 w-full，正文宽约 700），字就糊了；
# 400 宽只拉 1.75 倍，还顺带把「它贴在画面右上角」这件事也拍进去了。
$U6LB  = @{ X = 1053; Y = 180; W = 400; H = 160 }

# 输出面板 / 整个视口，给 Play-Stand 当裁剪矩形用
$U6OUT = @{ X = 0; Y = 788; W = 1000; H = 100 }
$U6VP  = @{ X = 367; Y = 167; W = 1086; H = 612 }

# 计分板里 Points 那个数字在裁剪图内的红框（几十上百的数也框得住）
$U6LBBOX = @{ t = 'box'; x = 300; y = 94; w = 92; h = 30 }

# ── 公共动作 ─────────────────────────────────────────────────

# 关掉所有打开的脚本文档。换脚本宿主前必须调 —— 见文件头的警告。
function U6-CloseDocs {
  RunLua 'local SE=game:GetService("ScriptEditorService") for _,d in ipairs(SE:GetScriptDocuments()) do if not d:IsCommandBar() then d:CloseAsync() end end print("docs closed")' 1200
}

# 把 Workspace 和 ServerScriptService 里的脚本全删掉，再在 SSS 下建一个干净的。
# 输出类截图的前置动作：Play 会跑**所有**脚本，多留一个就在输出里多一行。
# ⚠️ 只扫 workspace 是不够的，这个单元的主力脚本躺在 SSS 里。
function U6-FreshScript {
  RunLua 'local SSS=game:GetService("ServerScriptService") for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end for _,v in ipairs(SSS:GetChildren()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end local s=Instance.new("Script") s.Name="Script" s.Parent=SSS print("fresh script in SSS")' 1400
}

# 代码区里第 n 行（1 起）在裁剪图内的 y。行距 15.5px，顶上还有约 4px 边距。
# ⚠️ CodeRows 不能再 +4：多这 4px 红框底边就压到下一行的字上。
function CodeRow([int]$N) { [int](($N - 1) * 15.5 + 4) }
function CodeRows([int]$N) { [int]($N * 15.5) }

# 代码区字宽实测 8.08px/列（行号栏占左边 57px），中文算 2 列。
# 下限 360：网页上会被 CSS 拉到约 700px，短代码裁太窄就糊了。
function CodeWidth([int]$Cols) { [math]::Max(360, [int](57 + $Cols * 8.08 + 20)) }
function BoxW([int]$Cols) { [int](57 + $Cols * 8.08 + 10 - 28) }

# 把聊天窗关掉（**必须在 Play 模式里跑**，走的是客户端语境）。
#
# ⚠️ 一进游戏左上角就挂着一条系统消息「Roblox 会对所支持语言自动进行聊天翻译」。
#    它**不会自己淡出**（实测等到 25 秒还在），而且渲染在 ☰ 菜单**上面**，
#    正好糊在「商店」那一行上，6.4-s2 直接废掉。
# ⚠️ 别用点 unibar 第三个图标（💬）的办法：那是个**切换**，而且状态会被记住 ——
#    脚本每跑一次就反转一次，第二次重拍反而把聊天又打开了（踩过）。
#    SetCoreGuiEnabled 是幂等的，跑几次都是关。
function U6-HideChat {
  RunLua 'game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false) print("chat hidden")' 1500
}

# 把小人搬到某块垫子的正上方（**Play 模式里跑**，客户端语境；本地角色的
# 网络所有权在客户端，PivotTo 立刻生效）。抬 4 studs 让它自己落下去。
#
# ⚠️ 这个单元所有「踩上去才有的图」都得靠它。Touched 没法在编辑模式伪造，
#    而**把垫子搬到出生点上并不够**：SpawnLocation 是 12×12，Roblox 会在这块
#    区域里**随机挑一个点**放小人，6×6 的垫子（课文的规格）接不住 —— 实测
#    小人落在垫子旁边，一次 Touched 都没触发，输出面板空空如也，排查了一轮。
#    单元 4 的 U4-AtSpawn 之所以能成，是因为那块 MagicFloor 有 14×14，比出生点还大。
#
# $Delay 是**故意**的，不是保险：命令栏每跑一条都会往输出面板写一行回显，
# 想要一块「只有脚本自己打的字」的干净面板就得在搬人**之后**再清一次 —— 可那样
# 落地那一瞬间的一大串 Touched 就被一起清掉了（第一版拍出来只有 (x2)，
# 跟课文说的「触发了十几次」对不上）。改成 task.delay 把搬人排到 3 秒后：
# 先清面板，再落人，落地那一波就完整留在面板里了。
function U6-StandOn([string]$PartName, [double]$Delay = 3) {
  RunLua "local pl=game:GetService(`"Players`").LocalPlayer local c=pl.Character local t=workspace:FindFirstChild(`"$PartName`",true) if c and t then task.delay($Delay,function() c:PivotTo(CFrame.new(t.Position+Vector3.new(0,4,0))) end) end print(`"stand on $PartName after $Delay s`")" 1500
}

# 真进 Play 模式 → 等小人加载 → 关聊天 →（可选）把小人搬到某块垫子上 →
# 再等 $DwellSec 攒分 / 攒消息 → 裁一块屏幕矩形 → 停掉。
# 库里的 Play-ShotOut 只会裁输出面板，而且中途插不进动作；计分板 / 菜单 /
# 全景要的是别的矩形，还得先把人搬上垫子，所以另开一个。
#   -CleanLog  在**人落下来之前**清一次输出面板，把命令栏那几条回显
#              （`> game:GetService(...)` / `chat hidden` / `stand on Pad`）扫掉。
#              ClearOutput 连自己的回显一起清（回显早于它写入），正好。
#              搬人是 task.delay 排到 3 秒后的，所以清完面板人才落地 ——
#              见 U6-StandOn 的说明。$DwellSec 要把这 3 秒算进去。
#   $MidLua    给的话就跑这段 Lua 代替 U6-StandOn（6.8-s3 要的是「沿路跑一圈」，
#              不是「站一块垫子上」）。
function Play-Stand([string]$OutName, $R, [string]$StandOn = '', [int]$LoadSec = 12,
                    [int]$DwellSec = 0, [switch]$CleanLog, [string]$MidLua = '') {
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 600     # 焦点移出命令栏，F5 才收得到
  Send "{F5}" 1500
  Start-Sleep -Seconds $LoadSec
  U6-HideChat | Out-Null
  if ($MidLua) { RunLua $MidLua 1500 | Out-Null }
  elseif ($StandOn) { U6-StandOn $StandOn | Out-Null }
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

# ── 6.1 认识 Players 服务 ────────────────────────────────────

# 6.1-s1 · 资源管理器里 ServerScriptService 展开、下面挂着一个 Script
# 选中子节点会让父节点自动展开（资源管理器没有「展开」的 API）。
# ⚠️ Rig 要先 Stash：孩子的树里没有 Rig 这个节点，露出来图就对不上。
function U6-SssTree {
  Clear-Scene | Out-Null
  Stash-Rig | Out-Null
  U6-CloseDocs | Out-Null
  U6-FreshScript | Out-Null
  RunLua "game:GetService(`"Selection`"):Set({$U6S})" 1300 | Out-Null
  ShotRegion "_t1" "explorer" | Out-Null
  # Workspace 展开着 4 个孩子 → SSS 落在屏幕 y=405、它的 Script 在 425。
  # 裁 315 高（到 y=460）而不是 300：300 的话红框底边正好压在裁剪边缘上，
  # 下面那行 ServerStorage 还被切成半截，很脏。
  ReCrop "_t1" "_t1c" 0 145 362 315 | Out-Null
  Annotate "_t1c" "v_6_1-s1" @( @{ t='box'; x=3; y=252; w=355; h=44 } ) 2
}

# 6.1-s2 · 两行：拿到服务 + 打印它
function U6-PlayersCode {
  Set-Code $U6S @(
    'local Players = game:GetService("Players")'
    'print(Players)'
  ) -Open
  ShotCode "v_6_1-s2" 3 (CodeWidth 42) | Out-Null
}

# 6.1-s3 · 输出面板里一行 Players（真试玩，行尾是「- 服务器 - Script:2」）
function U6-PlayersOut {
  Play-ShotOut "_o61" 11 100 | Out-Null
  Annotate "_o61" "v_6_1-s3" @( @{ t='box'; x=6; y=56; w=380; h=21 } ) 2
}

# ── 6.2 PlayerAdded ──────────────────────────────────────────

$U6ADDED = @(
  'local Players = game:GetService("Players")'
  ''
  'Players.PlayerAdded:Connect(function(player)'
  '    print(player.Name)'
  'end)'
)

# 6.2-s1 · 5 行，红框框住第 3 行那句「装门铃」
function U6-AddedCode {
  Set-Code $U6S $U6ADDED -Open
  ShotCode "_ac" 6 (CodeWidth 44) | Out-Null
  Annotate "_ac" "v_6_2-s1" @( @{ t='box'; x=28; y=(CodeRow 3); w=(BoxW 44); h=(CodeRows 1) } ) 2
}

# 6.2-s2 · 输出面板里一行玩家名字
function U6-AddedOut {
  Play-ShotOut "_o62" 11 100 | Out-Null
  Annotate "_o62" "v_6_2-s2" @( @{ t='box'; x=6; y=56; w=380; h=21 } ) 2
}

# ── 6.3 leaderstats ──────────────────────────────────────────

# ⚠️ 这 7 行是照 06-03 课文里的代码块**一字不差**抄的（含那句中文注释），
#    改课文就要回来改这里。注释那行 77 列宽（中文一个字算 2 列）。
$U6LS = @(
  'local Players = game:GetService("Players")'
  ''
  'Players.PlayerAdded:Connect(function(player)'
  '    local leaderstats = Instance.new("Folder")'
  '    leaderstats.Name = "leaderstats"   -- 名字必须正好是 leaderstats（全小写）'
  '    leaderstats.Parent = player'
  'end)'
)

# 6.3-s1 · 7 行，红框框住第 5 行那个「暗号」
function U6-LsCode {
  Set-Code $U6S $U6LS -Open
  ShotCode "_lc" 8 (CodeWidth 77) | Out-Null
  Annotate "_lc" "v_6_3-s1" @( @{ t='box'; x=28; y=(CodeRow 5); w=(BoxW 36); h=(CodeRows 1) } ) 2
}

# 6.3-s2 · 试玩中的资源管理器：Players → 玩家名 → leaderstats
# 只有 Play 模式下 Players 底下才有东西 —— 这张必须在 F5 里面拍。
# 选中 leaderstats 会把 Players 和玩家两级都自动展开。
function U6-LsTree {
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 600
  Send "{F5}" 1500
  Start-Sleep -Seconds 12
  RunLua 'local p=game:GetService("Players"):GetPlayers()[1] local ls=p:FindFirstChild("leaderstats") game:GetService("Selection"):Set({ls}) print("SEL",tostring(ls))' 1600 | Out-Null
  ShotRegion "_t3" "explorer" | Out-Null
  # Play 模式下 Workspace 是**折叠**的（跟编辑模式不一样），树是
  # Workspace 205 / Players 225 / 玩家名 245 / leaderstats 265 / Backpack 285…
  # 所以 leaderstats 在裁剪图内的 y 是 265-145=120，行高 20。
  # 高 192 是凑着行边界切的（行高 20，PlayerGui 那行的下边界正好在这儿），
  # 给 200 会在底下留半行 PlayerScripts。
  ReCrop "_t3" "_t3c" 0 145 362 192 | Out-Null
  Annotate "_t3c" "v_6_3-s2" @( @{ t='box'; x=3; y=111; w=355; h=22 } ) 2
  Focus-Win | Out-Null
  Send "+{F5}" 4000
  Start-Sleep -Seconds 3
}

# ── 6.4 Points ───────────────────────────────────────────────

# ⚠️ 照 06-04 课文的完整代码块一字不差抄的，12 行。
$U6POINTS = @(
  'local Players = game:GetService("Players")'
  ''
  'Players.PlayerAdded:Connect(function(player)'
  '    local leaderstats = Instance.new("Folder")'
  '    leaderstats.Name = "leaderstats"   -- 名字必须正好是 leaderstats（全小写）'
  '    leaderstats.Parent = player'
  ''
  '    local points = Instance.new("IntValue")'
  '    points.Name = "Points"'
  '    points.Value = 0'
  '    points.Parent = leaderstats'
  'end)'
)

# 6.4-s1 · 12 行完整计分板脚本（不画框，整段都是重点）
function U6-PointsCode {
  Set-Code $U6S $U6POINTS -Open
  ShotCode "v_6_4-s1" 13 (CodeWidth 77) | Out-Null
}

# 6.4-s3 + 6.4-s2 · 一次 Play 拍两张：先拍右上角的计分板，再点开左上角 ☰ 拍菜单
#
# ⚠️ 这两张顺序不能反。菜单里的「排行榜」是个**开关** —— 计分板已经开着了，
#    再点一下就把它关了。所以先拍开着的计分板，再拍菜单（只展开、不点下去），
#    最后按 ESC 收起来。
# ⚠️ 菜单是游戏内 GUI 不是 Windows 弹出层，不会被 Focus-Win 收掉，
#    但保险起见还是一次调用里做完。
function U6-Leaderboard0 {
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 600
  Send "{F5}" 1500
  Start-Sleep -Seconds 13
  U6-HideChat | Out-Null
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 500
  Shot "_full_lb0" | Out-Null
  Crop "_full_lb0" "v_6_4-s3" $U6LB.X $U6LB.Y $U6LB.W $U6LB.H | Out-Null
  # 左上角 unibar 的第二个图标 = ☰
  Focus-Win | Out-Null
  Click 461 203 1400
  Move-To $script:CBS.ParkX $script:CBS.ParkY
  Start-Sleep -Milliseconds 600
  Shot "_full_menu" | Out-Null
  # 620 宽而不是只裁菜单那 210：菜单又窄又高（近 500），单裁出来是个细长条，
  # 网页上等比放大后高得离谱。带上右边的游戏画面，比例才正常，也说明「这是游戏里」。
  Crop "_full_menu" "_menu" 367 167 620 500 | Out-Null
  Annotate "_menu" "v_6_4-s2" @( @{ t='box'; x=16; y=408; w=192; h=46 } ) 3
  Focus-Win | Out-Null
  Send "{ESC}" 800
  Send "+{F5}" 4000
  Start-Sleep -Seconds 3
}

# ── 6.5 找到碰到我的玩家 ─────────────────────────────────────

# 建这个单元的第二个主角：6×1×6 的黄色得分垫 + 里面一个空 Script。
# 规格跟课文 6.5 第 1 步一字对应（压扁 / 亮黄 / 改名 Pad / Anchored）。
# 用 PN 而不是 P：树上和面板上要显示给孩子看的真名 Pad。
function U6-MakePad {
  U6-CloseDocs | Out-Null
  Build-Demo 'local p=PN("Pad",Vector3.new(6,1,6),Vector3.new(0,0.5,0),M.Plastic,Color3.fromRGB(245,205,48)) local s=Instance.new("Script") s.Name="Script" s.Parent=p' 'Vector3.new(0,0.5,0)' | Out-Null
}

$U6FIND = @(
  'local pad = script.Parent'
  ''
  'pad.Touched:Connect(function(hit)'
  '    local player = game.Players:GetPlayerFromCharacter(hit.Parent)'
  '    if player then'
  '        print(player.Name)'
  '    end'
  'end)'
)

# 6.5-s2 · 8 行，红框框住第 4 行那个「把零件换成人」的小魔法
function U6-PadCode {
  Set-Code $U6P $U6FIND -Open
  ShotCode "_pc" 9 (CodeWidth 66) | Out-Null
  Annotate "_pc" "v_6_5-s2" @( @{ t='box'; x=28; y=(CodeRow 4); w=(BoxW 66); h=(CodeRows 1) } ) 2
}

# 6.5-s3 · 输出面板里「玩家名 (xN)」
# 一脚踩下去 Touched 触发好几次（脚/腿/身子各算一次），输出面板把连续重复的
# 消息合并成一行、后面记 (xN)。实测这次是 (x6)。
# ⚠️ 这个数字每次跑都不一样，课文里明说了「可能是 4，也可能是 9」，别写死。
function U6-PadOut {
  Play-Stand "_o65" $U6OUT "Pad" 12 8 -CleanLog
  Annotate "_o65" "v_6_5-s3" @( @{ t='box'; x=6; y=56; w=420; h=21 } ) 2
}

# ── 6.6 碰到就 +1 分 ─────────────────────────────────────────

$U6SCORE = @(
  'local pad = script.Parent'
  ''
  'pad.Touched:Connect(function(hit)'
  '    local player = game.Players:GetPlayerFromCharacter(hit.Parent)'
  '    if player then'
  '        player.leaderstats.Points.Value += 1'
  '    end'
  'end)'
)

# 6.6-s1 · 8 行，红框框住第 6 行的 += 1
function U6-ScoreCode {
  Set-Code $U6P $U6SCORE -Open
  ShotCode "_sc" 9 (CodeWidth 66) | Out-Null
  Annotate "_sc" "v_6_6-s1" @( @{ t='box'; x=28; y=(CodeRow 6); w=(BoxW 48); h=(CodeRows 1) } ) 2
}

# 6.6-s2 · 没有 debounce：踩一脚，分数一下子跳到 6
#
# ⚠️ 实机行为跟「教科书版」的 debounce 故事**不一样**，别照想象写课文（踩过）：
#    当前 Studio 里 Touched **不会**因为「人站在上面」持续刷。实测站着不动 10 秒
#    只有 7 分、来回挪 13 秒 11 分、原地跳 15 秒 9 分 —— 都不是「疯狂往上涨」。
#    真正的现象是**一次踩踏触发好几次**（脚 / 腿 / 身子各算一次），也就是 6.5-s3
#    那个 `(x6)`。所以这组对比拍的是「踩一脚」而不是「站十秒」：
#      无 debounce → 6 分 ／ 有 debounce → 2 分
#    课文 6.6 / 6.7 已经全部按这个改写过了，改这里的等待时间就要回去改课文的数字。
#
# ⚠️ 跟 6.7-s2 是一组**同机位对比图**：裁剪框（$U6LB）和 Play-Stand 的三个时间
#    参数必须一模一样，孩子上下滚页面才能读出「同样踩一脚，一个 6 一个 2」。
# ⚠️ DwellSec 只给 2：截图时刻 ≈ 落地后 1 秒。给 4 的话 debounce 那张会拍到 2 分
#    之后又解锁加了一次，变成 6 : 2 之外的别的数，对比就没那么干脆。
function U6-ScoreSpam {
  Play-Stand "_lb66" $U6LB "Pad" 12 2
  Annotate "_lb66" "v_6_6-s2" @( $U6LBBOX ) 3
}

# ── 6.7 debounce ─────────────────────────────────────────────

$U6DEB = @(
  'local pad = script.Parent'
  'local debounce = false'
  ''
  'pad.Touched:Connect(function(hit)'
  '    local player = game.Players:GetPlayerFromCharacter(hit.Parent)'
  '    if player and not debounce then'
  '        debounce = true'
  '        player.leaderstats.Points.Value += 1'
  '        task.wait(1)'
  '        debounce = false'
  '    end'
  'end)'
)

# 6.7-s1 · 12 行，红框框住第 7~10 那四行（上锁 → 加分 → 等一秒 → 开锁）
function U6-DebCode {
  Set-Code $U6P $U6DEB -Open
  ShotCode "_dc" 13 (CodeWidth 66) | Out-Null
  Annotate "_dc" "v_6_7-s1" @( @{ t='box'; x=28; y=(CodeRow 7); w=(BoxW 48); h=(CodeRows 4) } ) 2
}

# 6.7-s2 · 有 debounce：同样踩一脚，只涨 2 分。所有参数跟 6.6-s2 一模一样。
function U6-DebCalm {
  Play-Stand "_lb67" $U6LB "Pad" 12 2
  Annotate "_lb67" "v_6_7-s2" @( $U6LBBOX ) 3
}

# ── 6.8 单元成果 ─────────────────────────────────────────────

# 6.8-s1 · 资源管理器里右键 Pad 弹出的菜单，红框框住「重复」
#
# ⚠️ 右键 → 截图 **必须写在同一个函数里**：下一次工具调用开头的 Focus-Win
#    会让 Windows 弹出层失焦、自动收起。
# ⚠️ 右键的 x 要靠左压在图标/文字上（58 稳）。行名右边悬停会冒出一个圆形「＋」
#    快捷插入按钮，正好点在它上面时菜单根本不弹，而且完全不报错。
#
# 菜单项（选中一个 Part 时）：剪切 / 复制 / Copy As / 重复 / 删除 / 重命名 / …
# 「重复」= Duplicate，「复制」= Copy。课文原来写的「Duplicate（复制）」会让
# 孩子点错那一项，已改成「重复（Duplicate）」。
function U6-DupMenu {
  Clear-Scene | Out-Null
  U6-CloseDocs | Out-Null
  U6-MakePad | Out-Null
  RunLua 'game:GetService("Selection"):Set({workspace.Pad})' 1300 | Out-Null
  Focus-Win | Out-Null
  RClick 58 305 1300                 # 资源管理器里 Pad 那一行（Workspace 展开时的第 5 个孩子）
  Move-To 400 760
  Start-Sleep -Milliseconds 600
  Shot "_full_dup" | Out-Null
  Send "{ESC}" 600
  # 菜单从 (75,305) 起，到「重命名」下面那条分隔线约 y=740。带一点左边的树当背景。
  Crop "_full_dup" "_dup" 20 295 330 200 | Out-Null
  Annotate "_dup" "v_6_8-s1" @( @{ t='box'; x=48; y=86; w=168; h=22 } ) 2
}

# 6.8-s3 · 试玩全景：脚下一排得分垫，右上角计分板上有攒起来的分数
# 这张要的是「真正在玩的样子」，所以裁的是**整个视口**，不是那块牌子。
#
# 5 块垫子，第 1 块压在出生点上，往**斜前方**（-X -Z）一块块排开，小人站第 1 块。
# ⚠️ 别让路线正对着镜头笔直往后排（第一版就是 (0,0,-9) 一路直排）：试玩机位
#    在小人正后方，一条直线的路整条被小人的身子挡住，只露出两三个黄边。
#    斜着排 (-5,0,-8) 才能让后面几块从身侧铺出去，一眼看出「这是一条路」。
# ⚠️ 小人站**第 1 块**（离镜头最近的那块），不是中间某块：站中间的话前面那几块
#    在小人背后，看不见。
function U6-HeroPlay {
  Clear-Scene | Out-Null
  U6-CloseDocs | Out-Null
  RunLua 'local sp=workspace:FindFirstChildOfClass("SpawnLocation") local ws=workspace local base=sp.Position+Vector3.new(0,1,0) for i=1,5 do local p=Instance.new("Part") p.Name="Pad"..i p.Size=Vector3.new(6,1,6) p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Color=Color3.fromRGB(245,205,48) p.CFrame=CFrame.new(base+Vector3.new(-(i-1)*5,0,-(i-1)*8)) p.Parent=ws ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|").."Pad"..i.."|") end print("route built")' 1600 | Out-Null
  # 把带 debounce 的得分垫脚本塞进每一块（课文说「复制 Pad 时脚本会跟着复制」，
  # 这里等价地一块块塞，图上看到的就是「每块都能加分」）
  RunLua ('local ws=workspace for i=1,5 do local p=ws:FindFirstChild("Pad"..i) local s=Instance.new("Script") s.Name="Script" s.Source=table.concat({' + (($U6DEB | ForEach-Object { "[[" + $_ + "]]" }) -join ",") + '},"\n") s.Parent=p end print("route scripted")') 2000 | Out-Null
  # 让小人从最远那块一路踩回第 1 块 —— 分数是**真跑出来的**（每块 +1~2），
  # 停在第 1 块上收尾，正好是离镜头最近、构图最好的位置。
  # 只站着不动的话 13 秒才 4 分，成果图上说服力不够。
  $route = 'local pl=game:GetService("Players").LocalPlayer local c=pl.Character ' +
           'task.spawn(function() task.wait(2) for i=5,1,-1 do local t=workspace:FindFirstChild("Pad"..i) ' +
           'if t then c:PivotTo(CFrame.new(t.Position+Vector3.new(0,4,0))) end task.wait(1.7) end end) print("running route")'
  Play-Stand "v_6_8-s3" $U6VP -LoadSec 12 -DwellSec 14 -MidLua $route
}

# ── 全部 ─────────────────────────────────────────────────────
# 顺序不能随便换，有三条硬约束：
#  · 输出类要求「场景里只有该有的脚本」—— 每张输出图拍的都是**上一次 Set-Code
#    写进去的那段代码**跑出来的结果，换顺序就会拿错代码。
#  · 6.5 起 SSS 里必须已经是 6.4 那份计分板脚本（它不 print，不会污染输出面板），
#    Pad 的脚本才有 player.leaderstats.Points 可加。
#  · 资源管理器类（6.1-s1 / 6.3-s2 / 6.8-s1）要求 Rig 已 Stash，所以整批开头
#    Stash-Rig、结尾 Unstash-Rig。
function U6-All {
  U6-SssTree; U6-PlayersCode; U6-PlayersOut       # 6.1
  U6-AddedCode; U6-AddedOut                       # 6.2
  U6-LsCode; U6-LsTree                            # 6.3
  U6-PointsCode; U6-Leaderboard0                  # 6.4
  U6-MakePad; U6-PadCode; U6-PadOut               # 6.5 —— 脚本宿主换成 Pad
  U6-ScoreCode; U6-ScoreSpam                      # 6.6
  U6-DebCode; U6-DebCalm                          # 6.7
  U6-DupMenu; U6-HeroPlay                         # 6.8
  Unstash-Rig | Out-Null
  "拍完 18 张。逐张 Read $script:SD\v_6_*.png 核对，再跑 npm run shots:save"
}
