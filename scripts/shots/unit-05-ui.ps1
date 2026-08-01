# ══ 单元 5 的代码类 / 输出类截图 ════════════════════════════════
# 视口类在 unit-05.ps1（一张表批量跑）；这里 13 张每张步骤都不一样，一张一个函数。
# 样板是 unit-04-ui.ps1。坐标（代码区裁剪宽、输出面板的框）全是本机 1920x1080 实测。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-05-ui.ps1"
#   U5-All            # 除 5.7-s1 外全拍一遍
#   U5-LoopSpam       # 5.7-s1 单独拍，见下面的警告
#
# 这个单元的代码全躺在 **ServerScriptService** 下的一个 Script 里（$U5S），
# 一路 Set-Code 覆盖过去。课文里 5.3 / 5.6 的脚本其实住在 Part 里，但代码类截图
# 只裁编辑器的文字区，宿主是谁画面上看不出来 —— 用同一个脚本对象最省事，也免得
# Play 模式下多一个脚本多一行输出。
#
# ⚠️ 5.7-s1 要真跑一个没有 task.wait 的 while，Studio 会硬卡十几秒才被脚本超时
#    保护掐掉。**放到最后、等别的图都 shots:save 进库之后再拍** —— 万一 Studio
#    崩了，重开会丢掉 Rig（得重跑 New-Rig），前面的图不能跟着一起赔进去。

$U5S = 'game:GetService("ServerScriptService").Script'

# ── 公共动作 ─────────────────────────────────────────────────

# 把 Workspace 和 ServerScriptService 里的脚本全删掉，再在 SSS 下建一个干净的。
# 输出类截图的前置动作：Play 会跑**所有**脚本，多留一个就在输出里多一行。
function U5-FreshScript {
  RunLua 'local SSS=game:GetService("ServerScriptService") for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end for _,v in ipairs(SSS:GetChildren()) do if v:IsA("LuaSourceContainer") then v:Destroy() end end local s=Instance.new("Script") s.Name="Script" s.Parent=SSS print("fresh script in SSS")' 1400
}

# 代码区里第 n 行（1 起）在裁剪图内的 y。行距 15.5px，顶上还有约 4px 边距。
# ⚠️ CodeRows 不能再 +4：红框高度多这 4px，框底就会压到下一行的字上
#    （5.6-s2 的框把第 8 行的 end 划了一道）。
function CodeRow([int]$N) { [int](($N - 1) * 15.5 + 4) }
function CodeRows([int]$N) { [int]($N * 15.5) }

# 代码区的字宽实测 8.08px/列（行号栏占掉左边 57px），中文算 2 列。
# 裁剪宽度 = 57 + 最长行列数 × 8.08 + 20 余量。⚠️ 别照感觉估：5.5-s1 / 5.8-s1
# 第一版按 7.2px/列 算，最长那行 math.random 都被切在半截上。
# 下限 360：网页上 <Shot> 是 w-full，会被 CSS 拉到正文宽度（约 700px）。
# 按公式算 while true do 那种短代码只有 220 宽，拉伸 3 倍字就糊了。
# 360 起步 = 最多拉 1.9 倍，跟单元 3/4 那批代码图（420~520）看起来是一套的。
function CodeWidth([int]$Cols) { [math]::Max(360, [int](57 + $Cols * 8.08 + 20)) }

# 红框右边界：框住第 $Cols 列为止的一段代码。x 固定 28（压在行号栏右侧）。
function BoxW([int]$Cols) { [int](57 + $Cols * 8.08 + 10 - 28) }

# ── 5.1 if ───────────────────────────────────────────────────

$U5IF = @(
  'local score = 20'
  ''
  'if score > 10 then'
  '    print("你赢了！")'
  'end'
)

# 5.1-s1 · 5 行 if 代码
function U5-IfCode {
  Clear-Scene | Out-Null            # 视口类留下的跑道/熔岩，Play 时会一起进场
  U5-FreshScript | Out-Null
  Stash-Rig | Out-Null              # 小人在 Workspace 里会跟着 Play 一起动，先收走
  Set-Code $U5S $U5IF -Open
  ShotCode "v_5_1-s1" 6 (CodeWidth 22) | Out-Null
}

# 5.1-s2 · 输出面板里一行「你赢了！」（真试玩，行尾是「- 服务器 - Script:4」）
function U5-IfOut {
  Play-ShotOut "_o51" 10 100 | Out-Null
  Annotate "_o51" "v_5_1-s2" @( @{ t='box'; x=6; y=56; w=400; h=21 } ) 2
}

# 5.1-s3 · 把 20 改成 5，输出面板一片空白
# 这张**不画红框** —— 要表达的正是「什么都没有」，框住一片空白反而像出了错。
# 裁到 100 高是为了留住上面那条「输出」标题栏，不然孩子认不出这是哪个窗口。
function U5-IfOutEmpty {
  Set-Code $U5S (@('local score = 5') + $U5IF[1..4])
  Play-ShotOut "v_5_1-s3" 10 100 | Out-Null
}

# ── 5.2 else ─────────────────────────────────────────────────

$U5ELSE = @(
  'local score = 8'
  ''
  'if score > 10 then'
  '    print("你赢了！")'
  'else'
  '    print("还差一点！")'
  'end'
)

# 5.2-s1 · 7 行代码，红框框住 else + 它下面那行 print（第 5、6 行）
function U5-ElseCode {
  Set-Code $U5S $U5ELSE -Open
  ShotCode "_ec" 8 (CodeWidth 25) | Out-Null
  Annotate "_ec" "v_5_2-s1" @( @{ t='box'; x=28; y=(CodeRow 5); w=(BoxW 23); h=(CodeRows 2) } ) 2
}

# 5.2-s2 · 输出「还差一点！」
function U5-ElseOutLose {
  Play-ShotOut "_o52" 10 100 | Out-Null
  Annotate "_o52" "v_5_2-s2" @( @{ t='box'; x=6; y=56; w=410; h=21 } ) 2
}

# 5.2-s3 · 把 8 改成 15，走另一条路 → 输出「你赢了！」
function U5-ElseOutWin {
  Set-Code $U5S (@('local score = 15') + $U5ELSE[1..6])
  Play-ShotOut "_o53" 10 100 | Out-Null
  Annotate "_o53" "v_5_2-s3" @( @{ t='box'; x=6; y=56; w=400; h=21 } ) 2
}

# ── 5.3 while ────────────────────────────────────────────────

# 5.3-s1 · 6 行 while 代码
function U5-WhileCode {
  Set-Code $U5S @(
    'local part = script.Parent'
    ''
    'while true do'
    '    part.BrickColor = BrickColor.Random()'
    '    task.wait(1)'
    'end'
  ) -Open
  ShotCode "v_5_3-s1" 7 (CodeWidth 41) | Out-Null
}

# ── 5.4 for ──────────────────────────────────────────────────

# 5.4-s1 · 7 行 for 代码
function U5-ForCode {
  Set-Code $U5S @(
    'for i = 1, 5 do'
    '    local block = Instance.new("Part")'
    '    block.Size = Vector3.new(4, 1, 4)'
    '    block.Position = Vector3.new(i * 5, 5, 0)'
    '    block.Anchored = true'
    '    block.Parent = workspace'
    'end'
  ) -Open
  ShotCode "v_5_4-s1" 8 (CodeWidth 45) | Out-Null
}

# ── 5.5 math.random ──────────────────────────────────────────

# 5.5-s1 · 9 行代码。那行 Color3.fromRGB(math.random...) 有 95 列宽，
# 按 CodeWidth 算要 845 才露得全。这是本单元第二宽的一张，网页上缩到 700 宽
# 只掉一点点，还认得清。
function U5-RandCode {
  Set-Code $U5S @(
    'for i = 1, 10 do'
    '    local block = Instance.new("Part")'
    '    block.Size = Vector3.new(4, 1, 4)'
    '    block.Position = Vector3.new(i * 5, 5, 0)'
    '    block.Anchored = true'
    '    block.Material = Enum.Material.Neon'
    '    block.Color = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))'
    '    block.Parent = workspace'
    'end'
  ) -Open
  ShotCode "v_5_5-s1" 10 (CodeWidth 95) | Out-Null
}

# ── 5.6 熔岩判定 ─────────────────────────────────────────────

# 5.6-s2 · 10 行代码，红框框住 if humanoid then / Health = 0 / end（第 5、6、7 行）
function U5-LavaCode {
  Set-Code $U5S @(
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
  ) -Open
  ShotCode "_lc" 11 (CodeWidth 57) | Out-Null
  Annotate "_lc" "v_5_6-s2" @( @{ t='box'; x=28; y=(CodeRow 5); w=(BoxW 27); h=(CodeRows 3) } ) 2
}

# ── 5.7 无限循环 ─────────────────────────────────────────────

# 5.7-s2 · 好习惯版 4 行，红框框住 task.wait(1)（第 3 行）
function U5-GoodLoopCode {
  Set-Code $U5S @(
    'while true do'
    '    print("hi")'
    '    task.wait(1)'
    'end'
  ) -Open
  ShotCode "_gl" 5 (CodeWidth 18) | Out-Null
  Annotate "_gl" "v_5_7-s2" @( @{ t='box'; x=28; y=(CodeRow 3); w=(BoxW 16); h=(CodeRows 1) } ) 2
}

# 5.7-s1 · 输出面板里「hi (x4996)」+ 红字脚本超时
#
# ⚠️ 这张要真跑一个没有 task.wait 的 while，Studio 会硬卡半分钟。
#    **别放进 U5-All，等别的图都 shots:save 进库之后再单独跑。** 实测跑完了
#    Studio 能自己缓过来，但万一崩了，重开会丢掉 Rig（得重跑 New-Rig）。
#
# 实机行为（跟一开始设想的不一样，按这个来）：
#  · Luau 的脚本超时保护**不是 10 秒**就掐。从 F5 到红字出现实测约 30 秒，
#    所以 WaitSec 要给 35 —— 给 22 会在半路截图，那时计数才 x555，
#    跟课文说的「一秒里转成千上万次」对不上。等满了是 **x4996**，才对得上。
#  · 输出面板把连续重复的 hi 合并成一行、后面记 (xN)，行首一个 ▸ 可以展开。
#    ⚠️ 这个数字每次跑都不一样，课文里别写死。
#  · 掐断时还会补四行：红字 Script timeout: exhausted allowed execution time
#    + Stack Begin / Line 1 / Stack End。**红字那行比计数更有用** —— 孩子真写出
#    死循环时看到的就是它，所以裁剪要把它一起圈进来（H=90 正好切在它下边界，
#    再高就露出半行 Stack Begin，很脏）。
function U5-LoopSpam([switch]$Safe) {
  if ($Safe) {
    # 退路：有界的 for，一瞬间跑完不触发超时，只有 hi (xN) 这一行、没有红字
    Set-Code $U5S @('for i = 1, 5000 do', '    print("hi")', 'end')
  } else {
    Set-Code $U5S @('while true do', '    print("hi")', 'end')
  }
  Play-ShotOut "_o71" 35 100 | Out-Null      # 这张只为把消息跑出来
  Focus-Win | Out-Null
  Wheel 500 900 20                           # 输出面板滚回顶，从第一条开始裁
  ShotOut "_o71c" 90 | Out-Null
  Annotate "_o71c" "v_5_7-s1" @( @{ t='box'; x=6; y=54; w=300; h=19 } ) 2
}

# ── 5.8 单元成果代码 ─────────────────────────────────────────

# 5.8-s1 · 18 行成果代码。最长那行 103 列（8 空格缩进 + 95），按 CodeWidth 要 909。
# 这是全单元最宽的一张：18 行 × 15.5 = 279 高、909 宽，网页上缩到 700 还剩 77%，
# 字偏小但还认得清 —— 成果课的代码就这么长，拆成两张反而看不出「一整屏」的份量。
# ⚠️ 这几行是照 05-08 课文里的代码块**一字不差**抄的，改课文就要回来改这里。
function U5-HeroCode {
  Set-Code $U5S @(
    'local blocks = {}'
    ''
    'for i = 1, 10 do'
    '    local block = Instance.new("Part")'
    '    block.Size = Vector3.new(4, 1, 4)'
    '    block.Position = Vector3.new(i * 5, 5, 0)'
    '    block.Anchored = true'
    '    block.Material = Enum.Material.Neon'
    '    block.Parent = workspace'
    '    blocks[i] = block'
    'end'
    ''
    'while true do'
    '    for i = 1, 10 do'
    '        blocks[i].Color = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))'
    '    end'
    '    task.wait(0.5)'
    'end'
  ) -Open
  ShotCode "v_5_8-s1" 19 (CodeWidth 103) | Out-Null
}

# ── 全部（不含 5.7-s1）────────────────────────────────────────
# 顺序不能随便换：输出类要求「场景里只有这一个脚本」，而每张输出图拍的都是
# **上一次 Set-Code 写进去的那段代码**跑出来的结果 —— 换了顺序就会拿错代码。
function U5-All {
  U5-IfCode; U5-IfOut; U5-IfOutEmpty            # 5.1
  U5-ElseCode; U5-ElseOutLose; U5-ElseOutWin    # 5.2
  U5-WhileCode                                  # 5.3
  U5-ForCode                                    # 5.4
  U5-RandCode                                   # 5.5
  U5-LavaCode                                   # 5.6
  U5-GoodLoopCode                               # 5.7-s2（s1 最后单独跑）
  U5-HeroCode                                   # 5.8
  Unstash-Rig | Out-Null
  "拍完 12 张（5.7-s1 未拍）。Read $script:SD\v_5_*.png 核对，再跑 npm run shots:save"
}
