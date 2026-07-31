# ══ 单元 3 的面板类 / 代码类 / 输出类截图 ════════════════════════
# 视口类在 unit-03.ps1（一张表批量跑）；这里 13 张每张步骤都不一样，一张一个函数。
# 样板是 unit-02-ui.ps1，新增的两类能力（写代码、真试玩拿输出）在 lib\code.ps1。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-03-ui.ps1"
#   U3-All                     # 按剧情顺序全拍一遍
#   U3-Insert                  # 或者单张重拍
#
# ⚠️ 这个单元有两条跟单元 2 完全不同的约束：
#
#  1) 右键菜单 / 弹出列表**一换进程就被关掉** —— 每次 PowerShell 调用开头的
#     Focus-Win（SetForegroundWindow）会让弹出层失焦自动收起。所以「右键 →
#     悬停子菜单 → 点某项 → 截图」必须写在**同一个函数**里一口气做完，
#     中间不能拆成两次工具调用。
#
#  2) 输出面板类的图**必须真按 F5 进 Play 模式**（Play-ShotOut）。命令栏 print
#     出来的行尾是「- 编辑」还多一行 `> print(...)` 回显，孩子屏幕上不长那样；
#     Play 模式里是「- 服务器 - Script:2」，跟孩子看到的一模一样。
#     而且 Play 模式里**所有** Workspace 脚本都会跑 —— 多留一个脚本就会在输出里
#     多一行，图就脏了。所以每个输出类函数开头都要先清掉别的脚本。

# 把 Workspace 里的脚本全删掉（含 CB 演示部件里的）。输出类截图的前置动作。
function U3-NoScripts {
  RunLua 'for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end print("scripts cleared")' 1000
}

# 建一个「MyPart 里装着 Script」的演示体。MyPart 用 PN 建，名字记进 CBX，
# Clear-Scene 收工时能一起删掉；Script 是它的孩子，跟着父级一起走。
function U3-MakeMyPart([string]$Name = "MyPart") {
  Build-Demo "local p=PN(`"$Name`",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Plastic) local s=Instance.new(`"Script`") s.Name=`"Script`" s.Parent=p" 'Vector3.new(0,3,0)'
}

# 3.1-s1 + 3.1-s2 · 右键 Workspace → 插入 → 插入对象… → 搜 Script
# 顺手把 Script 真插进去 —— 后面 3.1-s3 要拍它自带的那行默认代码。
function U3-Insert {
  Clear-Scene | Out-Null
  U3-NoScripts | Out-Null                 # 树里只留 Camera/Terrain/SpawnLocation/Baseplate
  Set-Clipboard -Value "Script"           # 搜索框走剪贴板，别用 SendKeys 打字（中文输入法会吃字）
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 500
  Send "{ESC}" 300
  RClick 73 205 1200                      # 右键资源管理器第一行 Workspace
  Move-To 120 270; Start-Sleep -Milliseconds 1500    # 悬停「插入」等子菜单弹出（点也行，但悬停更稳）
  Move-To 200 270; Start-Sleep -Milliseconds 700
  Shot "_ins1" | Out-Null
  Click 305 291 1600                      # 「插入对象…」
  Click 404 293 500                       # 搜索框
  Send "^v" 1500
  Shot "_ins2" | Out-Null
  Click 360 320 2200                      # 列表第一项 Script → 真插进 Workspace
  Crop "_ins1" "_ins1c" 0 192 556 146 | Out-Null
  Annotate "_ins1c" "v_3_1-s1" @( @{ t='box'; x=266; y=89; w=140; h=20 } ) 2
  Crop "_ins2" "_ins2c" 302 274 248 118 | Out-Null
  Annotate "_ins2c" "v_3_1-s2" @( @{ t='box'; x=5; y=37; w=236; h=19 } ) 2
}

# 3.1-s3 · 资源管理器里的 Script + 中间打开的写代码窗口（同框）
# ⚠️ 资源管理器的排序**不是**创建顺序，也不是纯字母序：Camera/Terrain 钉在最前，
#    然后才是 Script(265) / SpawnLocation(285) / Baseplate(305)。行高 20px。
#    别照抄别的单元的行号，每次插完东西先 ShotWin 看一眼真实位置。
# 用真插出来的 Script：它自带默认代码 print("Hello world!")，正好对上课文那句
# 「里面已经有一行字了」。
function U3-ScriptTree {
  Focus-Win | Out-Null
  DblClick 90 265 1800                    # 双击 Script → 打开脚本编辑器
  RunLua 'game:GetService("Selection"):Set({workspace:FindFirstChildOfClass("Script")})' 1000
  Focus-Win | Out-Null
  Click $script:CBX.DocTabX2 $script:CBX.DocTabY2 800
  ShotWin "_st" | Out-Null
  # 只裁「树 + 代码区」这一块：整条 left 区域有 1453px 宽，网页上缩到 700px
  # 显示，代码就小得看不清了
  Crop "_st" "_stc" 0 145 920 272 | Out-Null    # 272 正好切在一行的下边界，不切半行
  Annotate "_stc" "v_3_1-s3" @( @{ t='box'; x=3; y=111; w=354; h=19 } ) 2
}

# 3.1-s4 · 「脚本」选项卡工具栏，框出「输出」按钮
# ⚠️ 这个版本的 Studio **没有**「视图/View」ribbon 选项卡：资源管理器/属性在
#    「主页」，输出/命令栏在「脚本」。课文原来写的 View 选项卡是错的，已改。
function U3-OutputBtn {
  Focus-Win | Out-Null
  Click 958 63 1200                       # 「脚本」选项卡
  ShotWin "_ob" | Out-Null
  Crop "_ob" "_obc" 110 78 660 66 | Out-Null
  Annotate "_obc" "v_3_1-s4" @( @{ t='box'; x=303; y=5; w=50; h=56 } ) 2
  Focus-Win | Out-Null
  Click 708 63 800                        # 切回「主页」，别把 Studio 留在别的选项卡上
}

# 3.2-s1 · 脚本里只有一行 print
function U3-PrintCode {
  Set-Code 'workspace:FindFirstChildOfClass("Script")' @('print("你好，Roblox！")') -Open
  ShotCode "v_3_2-s1" 2 380 | Out-Null
}

# 3.2-s2 · 左上角的 ▶️ 播放按钮
function U3-PlayBtn {
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 600
  ShotWin "_pb" | Out-Null
  Crop "_pb" "_pbc" 0 44 300 44 | Out-Null
  Annotate "_pbc" "v_3_2-s2" @( @{ t='ellipse'; x=96; y=2; w=34; h=38 } ) 2
}

# 3.2-s3 · 输出面板里那行「你好，Roblox！」（真试玩）
function U3-HelloOut {
  Play-ShotOut "_ho" 10 100 | Out-Null
  Annotate "_ho" "v_3_2-s3" @( @{ t='box'; x=4; y=56; w=420; h=19 } ) 2
}

# 3.3-s1 · 资源管理器里 Script 缩在 MyPart 下面一格
# 小技巧：资源管理器没有「展开节点」的 API，但选中**子节点**会自动展开父节点
function U3-MyPartTree {
  Clear-Scene | Out-Null
  U3-NoScripts | Out-Null
  U3-MakeMyPart | Out-Null
  Set-Code 'workspace.MyPart.Script' @('local part = script.Parent', 'print(part.Name)')
  RunLua 'game:GetService("Selection"):Set({workspace.MyPart.Script})' 1200
  ShotRegion "_mt" "explorer" | Out-Null
  ReCrop "_mt" "_mtc" 0 145 362 235 | Out-Null
  Annotate "_mtc" "v_3_3-s1" @( @{ t='box'; x=3; y=151; w=355; h=40 } ) 2
}

# 3.3-s2 · 输出面板里打出 MyPart（真试玩）
function U3-MyPartOut {
  Play-ShotOut "_mo" 10 100 | Out-Null
  Annotate "_mo" "v_3_3-s2" @( @{ t='box'; x=4; y=56; w=420; h=19 } ) 2
}

# 3.6-s1 · 每行带 -- 中文注释的代码（注释是绿色的）
# 注释一律对齐到第 51 列。⚠️ 中文在编辑器里是**双宽**，算列数时一个汉字算 2。
function U3-Comments {
  Set-Code 'workspace.MyPart.Script' @(
    'local part = script.Parent                       -- 找到我住的那个方块'
    'part.BrickColor = BrickColor.new("Bright red")    -- 把它变成亮红色'
    'part.Size = Vector3.new(8, 8, 8)                  -- 把它变大'
    'part.Material = Enum.Material.Neon                -- 让它发光'
  ) -Open
  ShotCode "v_3_6-s1" 5 700 | Out-Null
}

# 3.6-s2 · 故意把 print 写成 Print，输出面板冒红字（真试玩）
function U3-BugOut {
  Set-Code 'workspace.MyPart.Script' @(
    'local part = script.Parent                       -- 找到我住的那个方块'
    'part.BrickColor = BrickColor.new("Bright red")    -- 把它变成亮红色'
    'Print("方块变红啦！")                             -- 这里故意写错：P 大写了'
  )
  Play-ShotOut "_bo" 10 150 | Out-Null
  # 报错除了红字那行，下面还跟着蓝色的 Stack Begin / Line 3 / Stack End 三行。
  # 别嫌乱 —— 中间那行明写着「Line 3」，正好帮课文讲「红字会告诉你第几行」。
  Annotate "_bo" "v_3_6-s2" @( @{ t='box'; x=4; y=56; w=745; h=19 } ) 2
}

# 3.7-s1 · 单元成果脚本（4 行 + 注释）
function U3-HeroCode {
  Set-Code 'workspace.MyPart.Script' @(
    'local part = script.Parent                       -- 找到我住的那个方块（NeonBlock）'
    'part.BrickColor = BrickColor.new("Lime green")    -- 把颜色改成青柠绿'
    'part.Material = Enum.Material.Neon                -- 改成霓虹材质，让它发光'
    'print("方块准备好啦！")                            -- 在输出窗口里报个信'
  ) -Open
  ShotCode "v_3_7-s1" 5 900 | Out-Null
}

# 3.7-s3 · 单元大合照：小人站在发光的青柠绿霓虹方块旁边
# 要先 New-Rig + Prep-Rig（Rig 会留在 place 里，下个单元还能用）。
#
# 摆位踩过两个坑：
#  1) 局部 +X 在 yaw=210 时**既往画面左、也往镜头前**（旋转是绕 Y 轴的，x 位移
#     同时带来深度位移）。所以 x=8,z=-2 会把小人推得离镜头很近 → 被放大 + 切掉脚。
#     想让小人和方块「站在同一排」，给 x 配一个正的 z 往回推（这里 5.5 / 2.5）。
#  2) 对准点放在两者中间（x=1.8）而不是方块中心，合照才不会偏一边。
function U3-Hero {
  U3-NoScripts | Out-Null
  Focus-Win | Out-Null; Send "{ESC}" 400
  $geo = 'local p=P("gem",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Neon) p.BrickColor=BrickColor.new("Lime green") ' + (Rig-At 'Vector3.new(5.5,0,2.5)' 15)
  Build-Demo $geo 'Vector3.new(1.8,2.8,0)'
  Aim-Demo 'Vector3.new(1.8,2.8,0)' 11
  RunLua 'game:GetService("Selection"):Set({})' 700
  ShotRegion "v_3_7-s3" "vp"
}

# 按剧情顺序全拍。分三段，因为输出类要求「场景里只有一个脚本」，
# 顺序换了就会互相污染。
function U3-All {
  U3-Insert; U3-ScriptTree; U3-OutputBtn      # 3.1 —— Workspace 里一个 Script
  U3-PrintCode; U3-PlayBtn; U3-HelloOut       # 3.2 —— 还是那个 Script
  U3-MyPartTree; U3-MyPartOut                 # 3.3 —— 换成 MyPart 里的 Script
  U3-Comments; U3-BugOut                      # 3.6 —— 复用 MyPart 的 Script
  U3-HeroCode                                 # 3.7 代码
  U3-Hero                                     # 3.7 合照（要先 New-Rig / Prep-Rig）
  "拍完 13 张。逐张 Read $script:SD\v_3_*.png 核对，再跑 npm run shots:save"
}
