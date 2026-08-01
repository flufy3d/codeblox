# ══ 单元 4「变量与事件」的视口场景 ══════════════════════════════
# 坐标都是场景局部坐标：X 左右、Y 上下、Z 前后，原点在地面。
# ⚠️ 局部 +X 在画面**左**边；局部 −Z 是**朝镜头**这一侧。
#
# 这个单元的主角从头到尾就一块东西：MagicFloor —— 一块 14×1×14 的压扁地板。
# 5 张视口图讲的是它的四个状态：默认灰 → 有人站上去 → 被踩得变色 → 消失不见。
# 所以除了 4.3-s1，其余四张**机位完全一样**（同一个 lp / d / yaw / pitch），
# 孩子在页面上上下滚动时能直接对比出「哪儿变了」—— 换机位就白拍了。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   New-Rig; Prep-Rig                      # 小人还没建的话（4.3-s1 之后再建，见下）
#   . "scripts\shots\unit-04.ps1"
#   Shoot-Batch $U4 'sheet-u4' 2 -Verify

# 地板本体。用 PN（真名）而不是 P：这块东西在 4.3 的属性面板 / 资源管理器截图里
# 要以「MagicFloor」的身份出镜，两边用同一个名字才不会前后矛盾。
$U4FLOOR = 'PN("MagicFloor",Vector3.new(14,1,14),Vector3.new(0,0.5,0),M.Plastic)'

# 把小人挪到地图底下。4.3-s1 是「还没有人踩」的空地板，可这时候 Rig 已经建好了，
# 不赶走就会站在上一张的位置入镜。⚠️ 挪到 y=-400，别挪到 (0,0,0)：那儿离场景
# 原点 (150,0,0) 不算远，广角构图照样拍得到（rig.ps1 里踩过）。
$U4PARK = 'local r=ws:FindFirstChild("Rig") if r then r:PivotTo(CFrame.new(0,-400,0)) end '

# 小人站在地板顶面（地板中心 y=0.5、厚 1 → 顶面 y=1）。
# Rig-At 的 y 给「脚底所在高度」，所以是 1 而不是 0。
# TurnDeg=15：正对镜头太呆，偏一点点更像在走路。
$U4RIG = (Rig-At 'Vector3.new(0,1,0)' 15)

$U4 = [ordered]@{}

# 4.3-s1 · 空地板（还没起名、还没人踩）
# pitch 24（默认 20）：这是张「一块**压扁的**地板」的图，俯角低了就只看到一条边，
# 读不出它是块平板。⚠️ 别往上加过头 —— 超过 35 天空就没了，Baseplate 铺满整幅
# 变成一片灰纹理（SKILL.md 里 1.1-s3 踩过）。
# d=17.5 而不是跟别的图一样 13：⚠️「可见宽度≈2.5d」那条估算**只对对准点所在的
# 那个平面成立**。这张俯拍一块贴地的板子，离镜头近的那个角比对准点近好几 studs，
# 被透视放大，按 d=11 算出来「够宽」实际四个角全出画，d=15 近角还压着底边 ——
# 一路退到 17.5 才四边都留出余量。俯角越大、主体越贴地，就要退得越多。
$U4['4.3-s1'] = @{
  geo = $U4PARK + $U4FLOOR
  lp  = 'Vector3.new(0,0.5,0)'; d = 17.5; pitch = 24
}

# 4.4-s2 · 小人站上去了（地板还是默认灰，这一课只 print，没变色）
# 以下四张共用这套机位：对准点抬到 y=2.6（小人腰的高度），d=13 → 可见高度约
# 18 studs，正好装下 14 宽的地板 + 5.5 高的小人，四周还留一点余量。
$U4['4.4-s2'] = @{
  geo = $U4FLOOR + ' ' + $U4RIG
  lp  = 'Vector3.new(0,2.6,0)'; d = 13
}

# 4.6-s2 · 踩一脚，地板换了个颜色（BrickColor.Random 的效果）
# 用 Hot pink：跟 4.7-s2 的亮黄拉开距离，两张图放一起不会以为是同一张。
$U4['4.6-s2'] = @{
  geo = $U4FLOOR + ' ws.MagicFloor.BrickColor=BrickColor.new("Hot pink") ' + $U4RIG
  lp  = 'Vector3.new(0,2.6,0)'; d = 13
}

# 4.7-s2 · 成果第一步：先变色
$U4['4.7-s2'] = @{
  geo = $U4FLOOR + ' ws.MagicFloor.BrickColor=BrickColor.new("Bright yellow") ' + $U4RIG
  lp  = 'Vector3.new(0,2.6,0)'; d = 13
}

# 4.7-s3 · 成果第二步：Transparency=1 + CanCollide=false，地板没了
# ⚠️ 小人要落到 y=0（地面）而不是 y=1 —— 地板不挡人了，人就站在 Baseplate 上。
#    跟 4.7-s2 同机位同对准点，两张叠着看正好是「地板消失、人往下掉了一格」。
$U4['4.7-s3'] = @{
  geo = 'PN("MagicFloor",Vector3.new(14,1,14),Vector3.new(0,0.5,0),M.Plastic,nil,1) ' +
        'ws.MagicFloor.CanCollide=false ' + (Rig-At 'Vector3.new(0,0,0)' 15)
  lp  = 'Vector3.new(0,2.6,0)'; d = 13
}
