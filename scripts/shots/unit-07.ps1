# ══ 单元 7「组装一个完整 Obby」的视口场景 ══════════════════════
# 坐标都是场景局部坐标：X 左右、Y 上下、Z 前后，原点在地面。
# ⚠️ 局部 +X 在画面**左**边；局部 −Z 是**朝镜头**这一侧。
#
# 这个单元跟前面几个都不一样：**九节课搭的是同一条路**。所以下面不是
# 九组互不相干的场景，而是一条**基线路线** + 一课课往上叠的零件：
#
#   7.1 光秃秃的灰台阶 → 7.3 加蓝检查点 → 7.4 加橙闸门 → 7.5 加红熔岩
#   → 7.6 加终点拱门 → 7.9 全都在
#
# 所以下面每个场景都是前一个的**超集**，孩子上下翻页能看出自己的关卡是
# 怎么一块块长出来的。改布局时**只改 $U7X 和那几个 function**，别在单个
# 场景里硬写坐标，否则几张图之间会对不上。
#
# ⚠️ 两件这个单元独有的事：
#
# 1) **必须把 Baseplate 藏起来**（`Hide-Baseplate`）。课文 7.1 教的第一件事
#    就是「删掉大灰地板，路要悬空」—— 底下留着那块灰地板，图就跟课文对着干。
#    藏起来而不是删掉：拍完 `Show-Baseplate` 放回去，别的单元重拍还要用。
#    副作用是画面底下变成天空，构图反而更干净。
#
# 2) **起点那块板用真的 SpawnLocation**，不是 P() 造的假货。7.2 整节课都在讲
#    「它本来就在你的世界里」，图上就得是那块顶面印着放射状太阳纹的真板子。
#    `Spawn7` 把它搬进场景，收工时 `Reset-Spawn` 搬回原点 —— 它不带 CB_ 前缀
#    也不在 CBX 清单里，`Clear-Scene` 不会管它，只能手动还。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-07.ps1"
#   Hide-Baseplate; U7-Shoot
#   Show-Baseplate; Reset-Spawn        # 收工

# ── 路线布局（一处改，全单元跟着改）────────────────────────────
# 路沿局部 X 铺开，起点在 +X（画面左边 = 离镜头近 = 大而清楚）。
# 台面统一厚 1、中心 y=0.5，所以**顶面在 y=1** —— 底下所有 y 都从这个数算。
$U7X = @{
  Start = 26     # 起点：真 SpawnLocation，12×12
  Cp    = 13     # 检查点：蓝色 SpawnLocation，8×8
  Gate  = 1      # 闸门台：灰台阶 8×8，橙闸门立在它上面
  Lava  = -11    # 熔岩台：红色 Neon 板 8×8
  Fin   = -25    # 终点台：14×12，拱门立在它上面
}

# 一块普通灰台阶。$Z 用来摆熔岩旁边那条窄落脚位。
function Step7([string]$Name, [double]$X, [double]$W = 8, [double]$D = 8, [double]$Z = 0) {
  "P(`"$Name`",Vector3.new($W,1,$D),Vector3.new($X,0.5,$Z),M.Plastic,Color3.fromRGB(128,127,131)) "
}

# 把真的 SpawnLocation 搬进场景。$Green 打开就顺手染成课文 7.2 第 3 步那个绿。
# ⚠️ 用 CFrame 而不是 Position：场景整体带一个 yaw 旋转（YAWC），只写 Position
#    板子的朝向会跟路线拧着，顶面那圈太阳纹一眼就看出来是歪的。
function Spawn7([double]$X, [switch]$Green) {
  $col = if ($Green) { 'Color3.fromRGB(75,200,90)' } else { 'Color3.fromRGB(163,162,165)' }
  "local sp=ws:FindFirstChild(`"SpawnLocation`") if sp then sp.Anchored=true " +
  "sp.CFrame=base(Vector3.new($X,0.5,0)) sp.Color=$col end "
}

# 检查点：蓝色的 SpawnLocation。SpawnLocation 不是 Part，P()/PN() 造不出来，
# 只能自己 new 一个 —— 于是也得自己把名字登记进 CBX，否则清场认不出它。
function Cp7([string]$Name, [double]$X) {
  "local c=Instance.new(`"SpawnLocation`") c.Name=`"$Name`" c.Anchored=true c.Enabled=false " +
  "c.Size=Vector3.new(8,1,8) c.CFrame=base(Vector3.new($X,0.5,0)) " +
  "c.Color=Color3.fromRGB(45,130,225) c.Parent=ws " +
  "ws:SetAttribute(`"CBX`",(ws:GetAttribute(`"CBX`") or `"|`")..`"$Name`"..`"|`") "
}

# 闸门：一块又高又宽的橙方块，落下时正好把路堵死（底面贴着台面 y=1）。
# $Up 给 12 就是课文里 Vector3.new(0,12,0) 抬起来的那一态 —— 两张图机位一样，
# 只有这个数不同，孩子上下滚页面就能直接看出「抬起来了」。
function Gate7([double]$Up = 0) {
  $y = 6 + $Up
  "PN(`"MovingBlock`",Vector3.new(2,10,9),Vector3.new($($U7X.Gate),$y,0),M.Plastic,Color3.fromRGB(226,124,36)) "
}

# 熔岩：红色 Neon，铺在台阶上（比台面高一丁点，免得 z-fighting 闪烁）
$U7LAVA = "PN(`"Lava1`",Vector3.new(8,1,8),Vector3.new($($U7X.Lava),1.05,0),M.Neon,Color3.fromRGB(200,30,20)) "

# 终点拱门：两根柱子 + 一根横梁。横梁那块叫 FinishArch（课文里脚本按名字找它）。
# $Gold 打开 = 通关后那一态：只有横梁变 Neon 金，柱子不变 —— 对比才落在横梁上。
function Arch7([switch]$Gold) {
  $m = if ($Gold) { 'M.Neon' } else { 'M.Plastic' }
  $c = if ($Gold) { 'Color3.fromRGB(255,215,0)' } else { 'Color3.fromRGB(128,127,131)' }
  $x = $U7X.Fin
  "P(`"pillarL`",Vector3.new(1.5,10,1.5),Vector3.new($($x+4),6,0),M.Plastic,Color3.fromRGB(120,119,122)) " +
  "P(`"pillarR`",Vector3.new(1.5,10,1.5),Vector3.new($($x-4),6,0),M.Plastic,Color3.fromRGB(120,119,122)) " +
  "PN(`"FinishArch`",Vector3.new(11,1.5,1.5),Vector3.new($x,11.75,0),$m,$c) " +
  "PN(`"FinishPad`",Vector3.new(6,1,6),Vector3.new($x,1.5,0),M.Plastic,Color3.fromRGB(238,238,242)) "
}

# ── 基线路线 ─────────────────────────────────────────────────
# 7.1 那一版：全是灰台阶，什么机关都还没有。
$U7BASE = (Spawn7 $U7X.Start) +
          (Step7 'stepA' $U7X.Cp) +
          (Step7 'stepB' $U7X.Gate) +
          (Step7 'stepC' $U7X.Lava) +
          (Step7 'stepD' $U7X.Fin 14 12)

# 之后每课的路线 = 基线 + 这一课新加的东西（检查点那块把灰台阶换成蓝的）
$U7WITH_CP   = (Spawn7 $U7X.Start -Green) + (Cp7 'Checkpoint1' $U7X.Cp) +
               (Step7 'stepB' $U7X.Gate) + (Step7 'stepC' $U7X.Lava) + (Step7 'stepD' $U7X.Fin 14 12)
$U7WITH_LAVA = $U7WITH_CP + (Gate7) + $U7LAVA

# 把小人赶到地图外（没有它的那些图，免得它站在上一张的位置入镜）
$U7PARK = 'local r=ws:FindFirstChild("Rig") if r then r:PivotTo(CFrame.new(0,-400,0)) end '

# ── 机位 ─────────────────────────────────────────────────────
# 整条路从 +32 到 -32 共 64 长。按「可见宽度≈2.5d」反推 d≈26，留余量到 32。
# yaw 194：一排 60 多长的东西，斜角必须收窄到接近正对，不然最近那块被透视
# 顶出画面（单元 5/6 都在这儿栽过）。pitch 22 既看得见台面顶，又不至于俯到
# 天空全没（>35 就只剩地面纹理了 —— 何况这单元底下压根没有地面）。
$U7WIDE = @{ lp = 'Vector3.new(0,3,0)'; d = 32; yaw = 194; pitch = 22 }

# 闸门那一段的中景：两张（落下/抬起）共用，机位必须一模一样。
# lp 的 y 给 9、d 给 22 是按**抬起来那一态**算的：闸门顶到 y=23，对准点压低
# 或者距离收近，抬起来那张就会被画框切掉半截。
$U7GATECAM = @{ lp = "Vector3.new($($U7X.Gate),9,0)"; d = 22; yaw = 200; pitch = 16 }

# 拱门那一段的中景：同样两张（灰/金）共用一个机位。拱门顶 y=12.5。
$U7ARCHCAM = @{ lp = "Vector3.new($($U7X.Fin),6,0)"; d = 17; yaw = 205; pitch = 14 }

$U7 = [ordered]@{}

# ── 7.1 悬空的世界 ───────────────────────────────────────────
# s1 只有起点那块 SpawnLocation 孤零零悬在天上 —— 课文刚教完「把 Baseplate
# 删掉」，这张就是删完的样子。d=14 让板子占到画面小半幅，四周留大片天空，
# 「脚下是天空」这句话才有图为证。
$U7['7.1-s1'] = @{
  geo = $U7PARK + (Spawn7 $U7X.Start)
  lp  = "Vector3.new($($U7X.Start),1,0)"; d = 14; yaw = 200; pitch = 18
}
$U7['7.1-s2'] = @{ geo = $U7PARK + $U7BASE } + $U7WIDE

# ── 7.2 重生点 ───────────────────────────────────────────────
# s2 特写：要看清顶面那圈放射状太阳纹。pitch 提到 30 才看得见顶面图案（平视
# 只剩一条边）；但**俯角一大就得退得更远** —— d=9 时四个角全被透视顶出画面，
# 退到 12 才四边都留出余量（「可见宽度≈2.5d」只对对准点那个平面成立）。
$U7['7.2-s2'] = @{
  geo = $U7PARK + (Spawn7 $U7X.Start)
  lp  = "Vector3.new($($U7X.Start),1,0)"; d = 12; yaw = 200; pitch = 30
}
# s3 小人站在起点上。板顶 y=1，所以 Rig-At 给 1。TurnDeg 250 ≈ 侧身面朝路
# 延伸的方向（局部 −X，画面右边），像正要出发。对准点往 −X 偏 3，让身前
# 那段路也进画面，不然人杵在正中间看不出「要往哪走」。
$U7['7.2-s3'] = @{
  geo = (Spawn7 $U7X.Start -Green) + (Step7 'stepA' $U7X.Cp) + (Step7 'stepB' $U7X.Gate) +
        (Rig-At "Vector3.new($($U7X.Start),1,0)" 250)
  lp  = "Vector3.new($($U7X.Start - 3),3,0)"; d = 16; yaw = 205; pitch = 18
}

# ── 7.3 检查点 ───────────────────────────────────────────────
# 蓝板子要让人看出「在路当中」，所以不用全景，取起点到熔岩台这一段。
$U7['7.3-s2'] = @{
  geo = $U7PARK + $U7WITH_CP
  lp  = "Vector3.new($($U7X.Cp),2,0)"; d = 22; yaw = 198; pitch = 20
}

# ── 7.4 闸门（成组：机位完全一样，只差抬没抬起来）──────────────
$U7['7.4-s1'] = @{ geo = $U7PARK + $U7WITH_CP + (Gate7 0) }  + $U7GATECAM
$U7['7.4-s3'] = @{ geo = $U7PARK + $U7WITH_CP + (Gate7 12) } + $U7GATECAM

# ── 7.5 熔岩 ─────────────────────────────────────────────────
# 课文说「旁边留着一条窄窄的安全落脚位置」，所以熔岩台朝镜头这侧（−Z）
# 补一条 8×3 的窄板 —— 有它，图才说得通「躲得过去」。
$U7['7.5-s1'] = @{
  geo = $U7PARK + $U7WITH_CP + $U7LAVA + (Step7 'ledge' $U7X.Lava 8 3 -5.5)
  lp  = "Vector3.new($($U7X.Lava),2,0)"; d = 18; yaw = 202; pitch = 24
}

# ── 7.6 终点拱门（成组：灰 → 金，同机位）──────────────────────
$U7['7.6-s1'] = @{ geo = $U7PARK + (Step7 'stepD' $U7X.Fin 14 12) + (Arch7) }       + $U7ARCHCAM
$U7['7.6-s3'] = @{ geo = $U7PARK + (Step7 'stepD' $U7X.Fin 14 12) + (Arch7 -Gold) } + $U7ARCHCAM

# ── 7.9 毕业作品全景 ─────────────────────────────────────────
# 全都在：绿起点、蓝检查点、橙闸门、红熔岩、金拱门。这是整个单元的封面图，
# 拱门用金色那一态（通关后的样子，最好看）。
$U7FULL = $U7WITH_LAVA + (Step7 'ledge' $U7X.Lava 8 3 -5.5) + (Arch7 -Gold)
$U7['7.9-s1'] = @{ geo = $U7PARK + $U7FULL } + $U7WIDE

# ── 一键拍完这个单元的视口图 ─────────────────────────────────
function U7-Shoot { Shoot-Batch $U7 'sheet-u7' 2 }

# ── Baseplate / SpawnLocation 的藏与还 ───────────────────────
function Hide-Baseplate {
  RunLua 'local b=workspace:FindFirstChild("Baseplate") if b then b.Parent=game:GetService("ServerStorage") end print("baseplate hidden")' 900
}
function Show-Baseplate {
  RunLua 'local b=game:GetService("ServerStorage"):FindFirstChild("Baseplate") if b then b.Parent=workspace end print("baseplate back")' 900
}
# 收工时把重生点搬回原点、颜色和启用状态复原
function Reset-Spawn {
  RunLua 'local sp=workspace:FindFirstChild("SpawnLocation") if sp then sp.CFrame=CFrame.new(0,0.5,0) sp.Color=Color3.fromRGB(163,162,165) sp.Enabled=true end print("spawn reset")' 900
}
