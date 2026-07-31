# ══ 单元 3「第一个脚本」的视口场景 ══════════════════════════════
# 坐标都是场景局部坐标：X 左右、Y 上下、Z 前后，原点在地面。
# ⚠️ 局部 +X 在画面**左**边 —— 「从左到右依次是……」的排列要倒着写 x。
#
# 颜色一律用 BrickColor.new("名字") 而不是自己填 RGB：课文教的就是这几个
# 颜色名，用名字取色才保证「图上看到的」= 「孩子照抄那行代码得到的」。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-03.ps1"
#   Shoot-Batch $U3 'sheet-u3' 2 -Verify

$U3 = [ordered]@{}

# 3.4-s1 · 代码把方块改成亮红色（这一课还没教改大小/材质，所以是默认塑料）
$U3['3.4-s1'] = @{
  geo = 'local p=P("part",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Plastic) p.BrickColor=BrickColor.new("Bright red")'
  lp  = 'Vector3.new(0,3,0)'; d = 12
}

# 3.4-s2 · 颜色名对照表：课文 Callout 列的前 5 个颜色排一排
# 斜角收到 188（几乎正对）—— 这是张「色卡」，5 块要一样大、一眼数得清。
# 踩过：yaw=195 时这排在深度上前后差了 10 studs，最近那块被透视放大到出画面。
# 一排东西越长，斜角就得越小、距离越远。
$U3['3.4-s2'] = @{
  geo = 'local ns={"Bright red","Bright blue","Bright yellow","Lime green","Hot pink"} for i,n in ipairs(ns) do local p=P("c"..i,Vector3.new(6,6,6),Vector3.new((3-i)*8.6,3,0),M.Plastic) p.BrickColor=BrickColor.new(n) end'
  lp  = 'Vector3.new(0,3,0)'; d = 24; yaw = 188
}

# 3.5-s1 · Size 改成 8 + Material 改成 Neon：又大又红又发光
$U3['3.5-s1'] = @{
  geo = 'local p=P("part",Vector3.new(8,8,8),Vector3.new(0,4,0),M.Neon) p.BrickColor=BrickColor.new("Bright red")'
  lp  = 'Vector3.new(0,4,0)'; d = 15
}

# 3.5-s2 · 三种 Size 对照：(4,4,4) / (8,8,8) / (12,1,12)
# 从左到右 = x 从大到小。薄板要看出「扁」，所以别太正对，留一点俯侧角。
$U3['3.5-s2'] = @{
  geo = 'local function mk(n,sz,lp) local p=P(n,sz,lp,M.Neon) p.BrickColor=BrickColor.new("Bright red") end mk("small",Vector3.new(4,4,4),Vector3.new(13,2,0)) mk("big",Vector3.new(8,8,8),Vector3.new(0,4,0)) mk("slab",Vector3.new(12,1,12),Vector3.new(-15,0.5,0))'
  lp  = 'Vector3.new(0,3.5,0)'; d = 21; yaw = 205
}

# 3.7-s2 · 单元成果特写：发光的青柠绿霓虹方块
# ⚠️ 是 6×6×6 不是 8×8×8：3.7 的成果脚本只改颜色和材质，**没有**改 Size
#    （改 Size 是 3.5 和本课的 challenge）。跟单元 2 的演示方块保持同一个尺寸。
$U3['3.7-s2'] = @{
  geo = 'local p=P("part",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Neon) p.BrickColor=BrickColor.new("Lime green")'
  lp  = 'Vector3.new(0,3,0)'; d = 12
}
