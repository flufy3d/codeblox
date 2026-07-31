# ══ 单元 1 的界面类 / 面板类 / 菜单类 / 试玩类截图 ═══════════════
# 视口类在 unit-01.ps1（一张表批量跑）；这里 16 张每张步骤都不一样，一张一个函数。
# 样板是 unit-02-ui.ps1 / unit-03-ui.ps1。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-01-ui.ps1"
#   U1-All                     # 按剧情顺序全拍一遍
#   U1-PartMenu                # 或者单张重拍
#
# ⚠️ 单元 1 特有的三条约束：
#
#  1) **树类截图前必须 Stash-Rig**。孩子在单元 1 的 Workspace 里只有
#     Camera / Terrain / SpawnLocation / Baseplate，多一个 Rig 图就对不上了。
#     Park-Rig 只挪出镜头，树上照样露着 —— 要用 Stash-Rig 搬去 ServerStorage。
#
#  2) **右键资源管理器时 x 要靠左（58）**。鼠标悬停在某一行时，行尾会冒出一个
#     圆形「+」快捷插入按钮；右键正好点在它上面时**菜单根本不弹**，而且不报错，
#     排查了很久。单元 3 用 x=73 右键 Workspace 能成，是因为 Workspace 这行字长、
#     「+」被顶到更右边。行名短（台阶1、Part）时必须再往左。
#
#  3) 顶部工具栏那一条（1.2-s1 / 1.3-s1 / 1.6-s2）全部从**同一张全窗口图**里裁，
#     只是红框位置不同 —— 这样三张的取景是一致的，孩子不会觉得每张界面都不一样。

# ⚠️ 这个文件依赖 unit-01.ps1 里的 $PARK（迷你乐园几何），两个都要 dot-source。

# 台阶三级 + 地板（1.5-s2 打组用；1.5-s3 会把三级台阶收进「台阶组」）
$PARK_STEPS = @'
PN("地板",Vector3.new(40,1,40),Vector3.new(0,0.5,0),M.Concrete,Color3.fromRGB(170,170,175))
PN("台阶1",Vector3.new(12,1,4),Vector3.new(0,1.5,4),M.Plastic,Color3.fromRGB(235,90,90))
PN("台阶2",Vector3.new(12,1,4),Vector3.new(0,3.5,8),M.Plastic,Color3.fromRGB(245,195,70))
PN("台阶3",Vector3.new(12,1,4),Vector3.new(0,5.5,12),M.Plastic,Color3.fromRGB(110,200,120))
'@ -replace "`r?`n", " "

# 资源管理器右键菜单里各项相对「右键点击处 y」的偏移（本机实测，行距 ~22px）。
# ⚠️ 菜单项**随选中数量变**：多选时没有「重命名」（不能一次给三个东西改名），
#    它后面所有项整体上移一行。两套偏移分开记，别混用。
$U1MENU  = @{ 剪切=12; 复制=34; 重复=87; 删除=108; 重命名=131; 作为模型分组=162 }   # 单选
$U1MENUM = @{ 剪切=12; 复制=34; 重复=87; 删除=108; 作为模型分组=131 }                # 多选

# 资源管理器树行的屏幕 y（全新模板，行高 20px）。
$U1ROW = @{ Workspace=205; Camera=225; Terrain=245; SpawnLocation=265; Baseplate=285 }

# 自己用 Lua 插进 Workspace 的第 N 个部件落在哪一行（Baseplate 之后按插入顺序排）。
# ⚠️ 只在「一层平铺」的状态下成立：打完组之后顺序会重排（实测 台阶组(285) → 三级台阶 →
#    Baseplate(365) → 地板(385)）。**每次插完/改完结构先 ShotRegion explorer 看一眼真实行位**。
function U1-RowY([int]$N) { 285 + 20 * $N }

# ── 1.1-s2 · Studio 主界面导览（左=资源管理器、中=3D 视口、右=属性）─────
# 孩子刚新建完 Baseplate 看到的就是这个画面，所以：Rig 搬走、演示部件清空、
# 输出面板清干净。选中 Baseplate 是故意的 —— 右边属性面板空着会像坏了。
# 文字标签给 36pt：整图 1920 宽，网页上要缩到 ~700px，小于 30pt 就看不清了。
function U1-Overview {
  Stash-Rig | Out-Null
  Clear-Scene | Out-Null
  Aim-Demo 'Vector3.new(129.9,0,75)' 34          # 对准世界原点（SpawnLocation 那儿）
  RunLua 'game:GetService("Selection"):Set({workspace:FindFirstChild("Baseplate")}) game:GetService("LogService"):ClearOutput()' 900 | Out-Null
  ShotWin "_ov" | Out-Null
  Crop "_ov" "_ovc" 0 0 1920 790 | Out-Null      # 790 正好切在输出面板标题栏之上
  Annotate "_ovc" "v_1_1-s2" @(
    @{ t='text'; s='① 资源管理器'; x=10;   y=700; size=36 }
    @{ t='text'; s='② 3D 视口';    x=560;  y=700; size=36 }
    @{ t='text'; s='③ 属性';       x=1470; y=700; size=36 }
  ) 3
}

# ── 1.2-s1 · 主页选项卡最右边：「资源管理器」和「属性」两个按钮 ────────
# ⚠️ 课文原来写的「View（视图）选项卡 → Explorer」在当前 Studio 里不存在：
#    没有视图 ribbon 选项卡，这两个面板按钮在**主页**最右边。已改课文。
function U1-PanelBtns {
  Focus-Win | Out-Null
  Send "{ESC}" 300
  ShotWin "_rb" | Out-Null
  Crop "_rb" "_rbc" 640 78 650 68 | Out-Null
  Annotate "_rbc" "v_1_2-s1" @( @{ t='box'; x=415; y=4; w=104; h=58 } ) 2
}

# ── 1.6-s4 · 主页工具栏上的「锚固」按钮 ─────────────────────────
# 跟 1.2-s1 是**同一块**工具栏裁剪（x 640~1290），只换红框位置 —— 一个单元里的
# 按钮图取景一致，孩子才认得出「还是刚才那条工具栏」。
# 锚固按钮的格子：屏幕 991~1043（材质 809 / 颜色 859 / 群组 911 / 锁定 963 / 锚固 1015，间距 52）
# ⚠️ 必须**先选中一个部件**再拍：没有选中时 群组/锁定/锚固 三个按钮都是灰的（禁用），
#    拍出来跟孩子「选中方块之后点锚固」时看到的不一样。
function U1-AnchorBtn {
  Build-Demo 'PN("方块",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Plastic,Color3.fromRGB(225,120,90))' 'Vector3.new(0,3,0)' | Out-Null
  Select-Named "方块" | Out-Null
  Focus-Win | Out-Null
  ShotWin "_ab" | Out-Null
  Crop "_ab" "_abc" 640 78 650 68 | Out-Null
  Annotate "_abc" "v_1_6-s4" @( @{ t='box'; x=351; y=4; w=52; h=58 } ) 2
}

# ── 1.2-s2 · 「部件」按钮的下拉菜单，框出「方块」──────────────────
# 弹出层一换工具调用就被 Focus-Win 收起，所以「点开 → 截图」必须同一个函数里做完。
function U1-PartMenu {
  Focus-Win | Out-Null
  Send "{ESC}" 300
  Click 497 103 1500                             # 「部件」右侧的下拉箭头
  Shot "_pm" | Out-Null
  Send "{ESC}" 400
  Crop "_pm" "_pmc" 380 78 600 258 | Out-Null
  Annotate "_pmc" "v_1_2-s2" @( @{ t='box'; x=80; y=66; w=110; h=26 } ) 2
}

# ── 1.2-s3 · 资源管理器里的 Part + 3D 里高亮的方块（同框）──────────
function U1-PartTree {
  Clear-Scene | Out-Null
  Build-Demo 'PN("Part",Vector3.new(6,6,6),Vector3.new(0,3,0))' 'Vector3.new(0,3,0)' | Out-Null
  Aim-Demo 'Vector3.new(0,3,0)' 22               # d=15 时方块会被 1050 的裁剪切掉右半边
  Select-Named "Part" | Out-Null
  ShotWin "_pt" | Out-Null
  Crop "_pt" "_ptc" 0 145 1050 420 | Out-Null    # 树 + 视口左 2/3（方块在视口正中）
  Annotate "_ptc" "v_1_2-s3" @( @{ t='box'; x=3; y=150; w=354; h=20 } ) 2
}

# ── 1.3-s1 · 主页选项卡最左边：移动 / 缩放 / 旋转 三件套 ──────────
function U1-Tools {
  Focus-Win | Out-Null
  Send "{ESC}" 300
  ShotWin "_tl" | Out-Null
  Crop "_tl" "_tlc" 0 25 520 118 | Out-Null
  Annotate "_tlc" "v_1_3-s1" @( @{ t='box'; x=58; y=57; w=157; h=55 } ) 2
}

# ── 1.3-s2 · 选中方块后出现的红绿蓝箭头手柄 ──────────────────────
# 光用 Selection:Set 只有蓝色选框，没有箭头 —— 必须真的把「移动」工具点亮。
# 拍完记得点回「选择」，别把 Studio 留在移动工具上（后面误拖就把场景弄乱了）。
function U1-Handles {
  Clear-Scene | Out-Null
  Build-Demo 'PN("方块",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Plastic,Color3.fromRGB(225,120,90))' 'Vector3.new(0,3,0)' | Out-Null
  Aim-Demo 'Vector3.new(0,3,0)' 14
  Select-Named "方块" | Out-Null
  Focus-Win | Out-Null
  Click 84 110 900                               # 主页 →「移动」
  ShotVP "v_1_3-s2" | Out-Null
  Focus-Win | Out-Null
  Click 31 110 600                               # 点回「选择」
}

# ── 1.4-s1 · 属性面板：框出 Color 和 Material 两行 ────────────────
function U1-Props {
  Select-Named "方块" | Out-Null
  Props-Top
  ShotRegion "_pp" "props" | Out-Null
  ReCrop "_pp" "_ppc" 1458 145 452 250 | Out-Null   # 标题栏 +「外观」整段
  Annotate "_ppc" "v_1_4-s1" @(
    @{ t='box'; x=8; y=124; w=432; h=23 }        # Color
    @{ t='box'; x=8; y=148; w=432; h=23 }        # Material
  ) 2
}

# ── 1.4-s2 · 主页「颜色」按钮点开的六边形色板 ────────────────────
# ⚠️ 属性面板里的 Color 行点开**没有**色板，只是一个可编辑的 "163, 162, 165"
#    文本格（要再点左边小色块才弹取色器）。给孩子挑颜色，主页那块色板直观得多，
#    课文已按这个改。
function U1-ColorPalette {
  Focus-Win | Out-Null
  Send "{ESC}" 300
  Click 873 103 1600                             # 「颜色」右侧的下拉箭头
  Shot "_cp" | Out-Null
  Send "{ESC}" 400
  Crop "_cp" "_cpc" 690 78 580 450 | Out-Null
  Annotate "_cpc" "v_1_4-s2" @( @{ t='box'; x=148; y=2; w=54; h=60 } ) 2
}

# ── 1.5-s1 · 右键 → 重命名，正在把 Part 改成「地板」──────────────
# ⚠️ 课文原来写「在 Explorer 里双击方块的名字」—— 当前 Studio 双击**不进**改名
#    状态（实测双击没反应，后续 Ctrl+A 还会把整棵树全选中）。正解是右键 → 重命名。
# ⚠️ 改完名要把新名字补进 Workspace 的 CBX 清单，否则 Clear-Scene 认不出它、
#    这个部件会一直留在 place 里。
function U1-Rename {
  Clear-Scene | Out-Null
  Build-Demo 'PN("Part",Vector3.new(40,1,40),Vector3.new(0,0.5,0),M.Concrete,Color3.fromRGB(170,170,175))' 'Vector3.new(0,2,0)' | Out-Null
  Aim-Demo 'Vector3.new(0,2,0)' 34
  Select-Named "Part" | Out-Null
  Set-Clipboard -Value "地板"
  $y = U1-RowY 1                                 # 唯一一个自建部件 → 305
  Focus-Win | Out-Null
  Move-To 58 $y; Start-Sleep -Milliseconds 400   # x=58 靠左：别压到行尾那个「+」按钮
  RClick 58 $y 1600
  Click 110 ($y + $U1MENU['重命名']) 1200        # 「重命名」（单选菜单）
  Send "^a" 300
  Send "^v" 700
  Shot "_rn" | Out-Null
  Crop "_rn" "_rnc" 0 145 362 230 | Out-Null
  Annotate "_rnc" "v_1_5-s1" @( @{ t='box'; x=3; y=150; w=354; h=20 } ) 2
  Send "{ENTER}" 900
  RunLua 'workspace:SetAttribute("CBX",(workspace:GetAttribute("CBX") or "|").."地板|")' 700 | Out-Null
}

# ── 1.5-s2 · 右键菜单，框出「作为模型分组」──────────────────────
# ⚠️ 中文界面里打组叫**「作为模型分组」**（ribbon 上那个按钮叫「群组」），
#    课文原来写的「右键 → Group」对不上，已改。
function U1-GroupMenu {
  Build-Demo ($PARK_STEPS) 'Vector3.new(0,3,4)' | Out-Null
  Aim-Demo 'Vector3.new(0,3,4)' 30
  RunLua 'local S=game:GetService("Selection") local t={} for _,n in ipairs({"台阶1","台阶2","台阶3"}) do local p=workspace:FindFirstChild(n) if p then table.insert(t,p) end end S:Set(t)' 1000 | Out-Null
  $y = U1-RowY 2                                 # 地板 305、台阶1 325
  Focus-Win | Out-Null
  Move-To 58 $y; Start-Sleep -Milliseconds 400
  RClick 58 $y 1800
  Shot "_gm" | Out-Null
  Send "{ESC}" 500
  $cy = 300                                      # 裁剪原点 y
  Crop "_gm" "_gmc" 20 $cy 420 235 | Out-Null
  # 三个都选中 → 用**多选**那套偏移：325+131=456 是「作为模型分组」，行带 455~476
  Annotate "_gmc" "v_1_5-s2" @( @{ t='box'; x=38; y=($y + $U1MENUM['作为模型分组'] - $cy - 1); w=172; h=21 } ) 2
}

# ── 1.5-s3 · 整洁的树：「地板」+ 展开的「台阶组」──────────────────
# 打组走 Lua（菜单点下去只会生成默认名 "Model"，还得再改名），顺手把 台阶组
# 记进 CBX 好清场。选中**子节点**会让资源管理器自动展开父节点。
function U1-Tidy {
  RunLua 'local ws=workspace local m=Instance.new("Model") m.Name="台阶组" m.Parent=ws for _,n in ipairs({"台阶1","台阶2","台阶3"}) do local p=ws:FindFirstChild(n) if p then p.Parent=m end end ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|").."台阶组|") game:GetService("Selection"):Set(m:GetChildren())' 1400 | Out-Null
  ShotRegion "_td" "explorer" | Out-Null
  ReCrop "_td" "_tdc" 0 145 362 255 | Out-Null
  # 打组后的真实行位：台阶组 285、台阶1/2/3 305/325/345、Baseplate 365、地板 385。
  # 红框圈住「台阶组 + 三级台阶」整块（屏幕 276~356 → 裁剪原点 145 → 局部 131~211）
  Annotate "_tdc" "v_1_5-s3" @( @{ t='box'; x=3; y=131; w=354; h=80 } ) 2
}

# ── 1.6-s1 · 属性面板里 Anchored 打着勾 ──────────────────────────
# Anchored 在「部件」分类下（属性面板按分类排，不按字母），要往下滚 10 格。
function U1-Anchored {
  Select-Named "地板" | Out-Null
  Props-Top
  Props-Scroll -10
  ShotRegion "_an" "props" | Out-Null
  ReCrop "_an" "_anc" 1458 360 452 115 | Out-Null
  Annotate "_anc" "v_1_6-s1" @( @{ t='box'; x=8; y=27; w=432; h=24 } ) 2
}

# ── 1.6-s2 · 左上角的 ▶️ 试玩按钮 ───────────────────────────────
# ⚠️ 课文原来写「顶部中间的播放控件」—— 当前 Studio 在**左上角**，已改。
function U1-PlayBtn {
  Focus-Win | Out-Null
  Send "{ESC}" 300
  ShotWin "_pb" | Out-Null
  Crop "_pb" "_pbc" 0 25 520 118 | Out-Null
  Annotate "_pbc" "v_1_6-s2" @( @{ t='ellipse'; x=99; y=24; w=30; h=30 } ) 2
}

# ── 1.6-s3 · 小人站在台阶上 ─────────────────────────────────────
# 不进 Play 模式：编辑模式插的 Rig + PivotTo 摆位（见 lib\rig.ps1）。
# Rig-At 的 y 给「台阶顶面高度」就是脚踩在台阶上；TurnDeg=180 = 背对镜头，
# 也就是正朝着楼梯往上走。
# 机位跟 1.7-s1 保持一致（yaw 235 / pitch 18），一个单元里的乐园照片才像同一个地方。
# ⚠️ 这里**没有** Prep-Rig：Rig 是上个单元建好并上过色摆过姿势的，Prep-Rig 摆姿势
#    是往 Motor6D 的 C0 上累乘，再跑一次腿就掰过头了。换 place / 新建 Rig 之后才要
#    先 New-Rig + Prep-Rig（判断依据：Head.Color 是 1,0.8,0.4 就说明已经上过色了）。
function U1-OnSteps {
  Unstash-Rig | Out-Null
  $geo = $PARK + (Rig-At 'Vector3.new(0,4,4.5)' 200)   # y=4 是台阶2的顶面 → 脚踩在上面
  Build-Demo $geo 'Vector3.new(0,4.2,4.5)' 235 | Out-Null
  Aim-Demo 'Vector3.new(0,4.2,4.5)' 14 235 18          # 对准小人本人、凑近点，别拍成远景小蚂蚁
  RunLua 'game:GetService("Selection"):Set({})' 700 | Out-Null
  ShotRegion "v_1_6-s3" "vp" | Out-Null
}

# ── 1.7-s2 · 小人站在发光平台上（单元大合照）────────────────────
function U1-OnPlatform {
  $geo = $PARK + (Rig-At 'Vector3.new(0,8,13)' 205)    # y=8 是发光平台的顶面
  Build-Demo $geo 'Vector3.new(0,4.5,7)' 235 | Out-Null
  Aim-Demo 'Vector3.new(0,4.5,7)' 26 235 18
  RunLua 'game:GetService("Selection"):Set({})' 700 | Out-Null
  ShotRegion "v_1_7-s2" "vp" | Out-Null
}

# 按剧情顺序全拍。顺序不能随便换：
#   ① 树类/界面类要在 Rig 搬走、场景干净的状态下拍
#   ② U1-Props / U1-ColorPalette 要用 U1-Handles 建的那个「方块」，得排在它后面
#   ③ 1.5 那三张是**接力**的（改名 → 打组 → 整洁的树），中间不能插别的；
#      1.6-s1 也接着用 1.5 留下的「地板」
#   ④ 小人类最后拍（Unstash-Rig 之后树里就多了 Rig）
function U1-All {
  U1-Overview                                    # 1.1-s2
  U1-PanelBtns; U1-Tools; U1-PlayBtn; U1-AnchorBtn   # 1.2-s1 / 1.3-s1 / 1.6-s2 / 1.6-s4（都从窗口图上裁）
  U1-PartMenu; U1-PartTree                       # 1.2-s2 / 1.2-s3
  U1-Handles; U1-Props; U1-ColorPalette          # 1.3-s2 / 1.4-s1 / 1.4-s2
  U1-Rename; U1-GroupMenu; U1-Tidy; U1-Anchored  # 1.5-s1 → 1.5-s2 → 1.5-s3 → 1.6-s1（接力）
  U1-OnSteps; U1-OnPlatform                      # 1.6-s3 / 1.7-s2（要先 Unstash-Rig）
  "拍完 16 张。逐张 Read $script:SD\v_1_*.png 核对，再跑 npm run shots:save"
}
