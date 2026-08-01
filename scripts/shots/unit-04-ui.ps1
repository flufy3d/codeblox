# ══ 单元 4 的代码类 / 输出类 / 面板类截图 ══════════════════════
# 视口类在 unit-04.ps1（一张表批量跑）；这里 14 张每张步骤都不一样，一张一个函数。
# 样板是 unit-03-ui.ps1，坐标（$PROW、树的行 y、输出面板的裁剪框）全是本机
# 1920x1080 实测，换机器要重量。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-04-ui.ps1"
#   U4-All                     # 按剧情顺序全拍一遍
#   U4-TouchOut                # 或者单张重拍
#
# ⚠️ 这个单元比单元 3 多一条硬约束：**输出面板里的字要靠小人真的踩上去才出现**。
#    Touched 事件不能在编辑模式里伪造（命令栏调 :Fire() 也不行，事件是只读的），
#    所以 4.4 / 4.5 那两张输出图必须：把地板搬到**出生点正上方**（U4-AtSpawn），
#    F5 之后小人一落地就砸在它身上，Touched 连着触发好几次 —— 这恰好也是孩子
#    自己会看到的画面（好几行重复），课文里为此补了一个 Callout 解释。

# ── 公共动作 ─────────────────────────────────────────────────

# 把 Workspace 里的脚本全删干净。输出类截图的前置动作 ——
# Play 模式会跑**所有**脚本，多留一个就在输出里多一行。
function U4-NoScripts {
  RunLua 'for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end print("scripts cleared")' 1000
}

# 建一个「部件里装着 Script」的演示体。部件用 PN（真名，会进 CBX 清单），
# Script 是它的孩子，跟着父级一起被 Clear-Scene 收走。
function U4-MakePart([string]$Name, [string]$Size, [string]$Lp) {
  Build-Demo "local p=PN(`"$Name`",$Size,$Lp,M.Plastic) local s=Instance.new(`"Script`") s.Name=`"Script`" s.Parent=p" $Lp
}

# 把地板搬到出生点正上方，让试玩时的小人落在它身上。
# +1 而不是 +2：抬太高小人会卡在地板里侧面，抬太低又盖不住出生台。
function U4-AtSpawn([string]$Name = "MagicFloor") {
  RunLua "local sp=workspace:FindFirstChildOfClass(`"SpawnLocation`") local p=workspace:FindFirstChild(`"$Name`",true) if sp and p then p.Anchored=true p.CFrame=CFrame.new(sp.Position+Vector3.new(0,1,0)) end print(`"floor at spawn`")" 1200
}

# ── 4.1 变量是「贴标签的盒子」──────────────────────────────────

# 4.1-s1 · 就两行：local score = 0 / print(score)
# 这一课的脚本直接躺在 Workspace 下（课文 StudioStep 1 就是右键 Workspace 插的），
# 跟 4.2 起「脚本住在方块里」是两码事，别混。
function U4-VarCode {
  Clear-Scene | Out-Null
  U4-NoScripts | Out-Null
  RunLua 'local s=Instance.new("Script") s.Name="Script" s.Parent=workspace print("script added")' 1200
  Set-Code 'workspace:FindFirstChildOfClass("Script")' @('local score = 0', 'print(score)') -Open
  ShotCode "v_4_1-s1" 3 420 | Out-Null
}

# 4.1-s2 · 输出面板里一个 0（真试玩）
function U4-VarOut0 {
  Play-ShotOut "_o10" 10 100 | Out-Null
  Annotate "_o10" "v_4_1-s2" @( @{ t='box'; x=6; y=56; w=344; h=21 } ) 2
}

# 4.1-s3 · 把盒子里换成 100，拿出来的就变成 100
function U4-VarOut100 {
  Set-Code 'workspace:FindFirstChildOfClass("Script")' @('local score = 100', 'print(score)')
  Play-ShotOut "_o11" 10 100 | Out-Null
  Annotate "_o11" "v_4_1-s3" @( @{ t='box'; x=6; y=56; w=352; h=21 } ) 2
}

# ── 4.2 把方块存进变量 ───────────────────────────────────────

# 4.2-s1 · 资源管理器里 Script 缩在 Part 下面一格
# 小技巧：资源管理器没有「展开节点」的 API，但 Selection:Set({子节点}) 会自动
# 把父节点展开。⚠️ 树的行序不是创建顺序也不是字母序，拍之前先 ShotWin 看真实行位。
function U4-PartTree {
  Clear-Scene | Out-Null
  U4-NoScripts | Out-Null
  U4-MakePart "Part" 'Vector3.new(6,6,6)' 'Vector3.new(0,3,0)' | Out-Null
  RunLua 'game:GetService("Selection"):Set({workspace.Part.Script})' 1200
  ShotRegion "_p2t" "explorer" | Out-Null
  ReCrop "_p2t" "_p2tc" 0 145 362 196 | Out-Null
  Annotate "_p2tc" "v_4_2-s1" @( @{ t='box'; x=3; y=150; w=355; h=40 } ) 2
}

# 4.2-s2 · local part = script.Parent / print(part.Name)
function U4-PartCode {
  Set-Code 'workspace.Part.Script' @('local part = script.Parent', 'print(part.Name)') -Open
  ShotCode "v_4_2-s2" 3 460 | Out-Null
}

# 4.2-s3 · 输出面板里打出方块的名字 Part（真试玩）
function U4-PartOut {
  Play-ShotOut "_o23" 10 100 | Out-Null
  Annotate "_o23" "v_4_2-s3" @( @{ t='box'; x=6; y=56; w=368; h=21 } ) 2
}

# ── 4.3 事件是什么（准备 MagicFloor）─────────────────────────

# 建这一单元的主角：14×1×14 的压扁地板 + 里面一个空 Script
function U4-MakeFloor {
  Clear-Scene | Out-Null
  U4-NoScripts | Out-Null
  U4-MakePart "MagicFloor" 'Vector3.new(14,1,14)' 'Vector3.new(0,0.5,0)' | Out-Null
}

# 4.3-s2 · 属性面板「数据」分类里的 Name = MagicFloor
# ⚠️ 每张面板图开头都要 Props-Top：属性面板的滚动位置**不随选中新部件重置**，
#    上一张滚到底了，这一张按 $PROW 的坐标点下去会点到别的行（还可能顺手改掉值）。
function U4-FloorProps {
  Select-Named "MagicFloor" | Out-Null
  Props-Top
  ShotRegion "_fp" "props" | Out-Null
  # 只裁「数据」这一整个分类（数据 / Archivable / ClassName / Locked / Name / Parent）。
  # 整块属性面板有 665px 高，网页上缩到 700px 宽显示时字就糊了；裁到 145px
  # 高刚好留住上下文（能看出 Name 是「数据」类里的一行），字又够大。
  ReCrop "_fp" "_fpc" 1458 385 452 145 | Out-Null
  Annotate "_fpc" "v_4_3-s2" @( @{ t='box'; x=4; y=99; w=444; h=22 } ) 2
}

# 4.3-s3 · 资源管理器里 Script 缩在 MagicFloor 下面一格
function U4-FloorTree {
  RunLua 'game:GetService("Selection"):Set({workspace.MagicFloor.Script})' 1200
  ShotRegion "_ft" "explorer" | Out-Null
  ReCrop "_ft" "_ftc" 0 145 362 196 | Out-Null
  Annotate "_ftc" "v_4_3-s3" @( @{ t='box'; x=3; y=150; w=355; h=40 } ) 2
}

# ── 4.4 Touched ──────────────────────────────────────────────

# 经典 Touched 三段式（7 行，含两个空行）。缩进用 4 个空格而不是真 Tab：
# 制表符从剪贴板粘进命令栏会被当成「切换焦点」吃掉，而 Studio 编辑器把 Tab
# 也正好渲染成 4 列 —— 图上看不出区别。
$U4TOUCH = @(
  'local part = script.Parent'
  ''
  'local function onTouch(hit)'
  '    print("有人碰到我啦！")'
  'end'
  ''
  'part.Touched:Connect(onTouch)'
)

# 4.4-s1 · 那 7 行代码
function U4-TouchCode {
  Set-Code 'workspace.MagicFloor.Script' $U4TOUCH -Open
  ShotCode "v_4_4-s1" 8 520 | Out-Null
}

# 4.4-s3 · 输出面板里的「有人碰到我啦！（x12）」（真试玩）
# ⚠️ 实机跟原先设想的不一样，别按想象写红框：一脚踩下去 Touched 会触发十几次
#    （小人有脚/腿/身体好几个部件各碰各的），但**当前 Studio 的输出面板会把连续
#    重复的消息合并成一行**，在后面标 (x12)，行首给个 ▸ 可以展开。所以这里是
#    **一行**不是一片 —— 课文的 Callout 也照这个行为重写过了。
function U4-TouchOut {
  U4-AtSpawn "MagicFloor" | Out-Null
  Play-ShotOut "_o44" 12 100 | Out-Null
  Annotate "_o44" "v_4_4-s3" @( @{ t='box'; x=6; y=56; w=470; h=21 } ) 2
}

# ── 4.5 函数 ─────────────────────────────────────────────────

$U4FUNC = @(
  'local part = script.Parent'
  ''
  'local function onTouch(hit)'
  '    print("有人碰到我啦！")'
  '    print("脚步声～")'
  'end'
  ''
  'part.Touched:Connect(onTouch)'
)

# 4.5-s1 · 8 行代码，红框框住 function…end 之间的两行 print（「包裹里的东西」）
function U4-FuncCode {
  Set-Code 'workspace.MagicFloor.Script' $U4FUNC -Open
  ShotCode "_fc" 9 520 | Out-Null
  Annotate "_fc" "v_4_5-s1" @( @{ t='box'; x=28; y=51; w=250; h=38 } ) 2
}

# 4.5-s2 · 输出面板里两句话成对出现（真试玩）
# ⚠️ 两句话**交替**出现，所以不会像 4.4 那样被合并成 (xN)，会刷出十几行；
#    面板默认停在**最底下**，直接裁就是上下各半行的脏图。所以 Play 跑完之后
#    先把面板滚回顶（Play-ShotOut 结束时已经停了 Play，消息还留着），
#    从第一条开始裁 —— 第一对正好是「有人碰到我啦！」在上、「脚步声～」在下，
#    跟课文讲的顺序一致。
function U4-FuncOut {
  Play-ShotOut "_tmp45" 12 100 | Out-Null      # 只为把消息跑出来
  Focus-Win | Out-Null
  Wheel 500 900 20                             # 输出面板滚回顶
  # 122 而不是 100/130：行距 17px，这个高度正好切在第 4 行下边界，不露第 5 行的边
  ShotOut "_o45" 122 | Out-Null
  Annotate "_o45" "v_4_5-s2" @( @{ t='box'; x=6; y=57; w=430; h=36 } ) 2
}

# ── 4.6 碰到就变色 ───────────────────────────────────────────

# 4.6-s1 · print 换成 BrickColor.Random()
function U4-ColorCode {
  Set-Code 'workspace.MagicFloor.Script' @(
    'local part = script.Parent'
    ''
    'local function onTouch(hit)'
    '    part.BrickColor = BrickColor.Random()'
    'end'
    ''
    'part.Touched:Connect(onTouch)'
  ) -Open
  ShotCode "v_4_6-s1" 8 520 | Out-Null
}

# ── 4.7 单元成果 ─────────────────────────────────────────────

# 4.7-s1 · 9 行成果代码，每行带绿色中文注释
# 注释统一对到第 51 列。⚠️ 中文在编辑器里是**双宽**，算列数时一个汉字算 2；
# 行首那 4 个空格也要算进去。这几行是照 04-07 课文里的代码块**一字不差**抄的，
# 改课文就要回来改这里，否则图和课文对不上。
function U4-HeroCode {
  Set-Code 'workspace.MagicFloor.Script' @(
    'local part = script.Parent                        -- 找到我住的那块地板'
    ''
    'local function onTouch(hit)                       -- 碰到时要做的事，全打包进来'
    '    part.BrickColor = BrickColor.Random()         -- 先随机换一种颜色'
    '    part.Transparency = 1                         -- 再变透明，看不见了'
    '    part.CanCollide = false                       -- 也不再挡人，能穿过去'
    'end                                               -- 包裹到这里装完'
    ''
    'part.Touched:Connect(onTouch)                     -- 碰到就打开这个包裹'
  ) -Open
  ShotCode "v_4_7-s1" 10 900 | Out-Null
}

# ── 全部 ─────────────────────────────────────────────────────
# 顺序不能随便换：输出类要求「场景里只有这一个脚本」，而 4.3 起一直复用同一个
# MagicFloor.Script —— 换了顺序就会拿上一课的代码去拍下一课的输出。
function U4-All {
  U4-VarCode; U4-VarOut0; U4-VarOut100          # 4.1 —— Workspace 下的 Script
  U4-PartTree; U4-PartCode; U4-PartOut          # 4.2 —— 换成 Part 里的 Script
  U4-MakeFloor; U4-FloorProps; U4-FloorTree     # 4.3 —— 换成 MagicFloor 里的 Script
  U4-TouchCode; U4-TouchOut                     # 4.4 —— 地板搬到出生点，开始真踩
  U4-FuncCode; U4-FuncOut                       # 4.5
  U4-ColorCode                                  # 4.6 代码
  U4-HeroCode                                   # 4.7 代码
  "拍完 14 张。逐张 Read $script:SD\v_4_*.png 核对，再跑 npm run shots:save"
}
