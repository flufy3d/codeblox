# ══ 单元 2「属性魔法师」的视口场景 ══════════════════════════════
# 坐标都是场景局部坐标：X 左右、Y 上下、Z 前后，原点在地面。
# 整个场景会按 config 里的 SceneYawOffsetDeg 相对相机旋转，拿到 3/4 斜角。
#
# 用法：
#   . "...\lib\load.ps1"
#   . "...\scenes\unit-02.ps1"
#   Shoot-Batch $U2 'sheet-u2'

$U2 = [ordered]@{}

# 四种质感地砖。保持默认灰色 —— 忠于课程「这一步只改 Material」
$U2['2.1-s3'] = @{
  geo = 'local mats={M.Wood,M.Brick,M.Metal,M.Ice} for i,m in ipairs(mats) do P("tile"..i,Vector3.new(10,1,10),Vector3.new((i-2.5)*10.4,0.5,0),m) end'
  lp  = 'Vector3.new(0,0.5,0)'; d = 32
}

# Neon 小方块发光特写
$U2['2.2-s2'] = @{
  geo = 'P("neon",Vector3.new(4,4,4),Vector3.new(0,2,0),M.Neon,Color3.fromRGB(0,170,255))'
  lp  = 'Vector3.new(0,2,0)'; d = 11
}

# 发光核心装在半透明方块里
$U2['2.2-s3'] = @{
  geo = 'P("glass",Vector3.new(9,9,9),Vector3.new(0,4.5,0),M.Glass,Color3.fromRGB(200,235,255),0.55) P("core",Vector3.new(3.5,3.5,3.5),Vector3.new(0,4.5,0),M.Neon,Color3.fromRGB(0,190,255))'
  lp  = 'Vector3.new(0,4.5,0)'; d = 16
}

# 两根一样高的圆柱 + 顶上一颗球
# 两根柱子要读出「一样高」，所以斜角小一点、更正对，别让透视把高度拉开
$U2['2.3-s3'] = @{
  geo = 'CYL("colL",12,3,Vector3.new(-7,6,0),M.Concrete) CYL("colR",12,3,Vector3.new(7,6,0),M.Concrete) BALL("orb",4,Vector3.new(7,13.6,0),M.Neon,Color3.fromRGB(255,200,60))'
  lp  = 'Vector3.new(0,7,0)'; d = 24; yaw = 192
}

# Ctrl+V 出来的第二根柱子 —— 高亮表示「刚粘贴的那根」。
# 高亮必须放 post：相机步骤会清空选择
$U2['2.5-s1'] = @{
  geo = 'CYL("colL",12,3,Vector3.new(-7,6,0),M.Concrete) CYL("colR",12,3,Vector3.new(7,6,0),M.Concrete)'
  lp  = 'Vector3.new(0,7,0)'; d = 24; yaw = 192
  post = 'S:Set({ws:FindFirstChild("CB_colR")})'
}

# Anchored 的草地漂浮岛：对准点压到岛下方，让地面和影子进画面，才看得出「浮着」
$U2['2.6-s1'] = @{
  geo = 'P("isle",Vector3.new(28,2,28),Vector3.new(0,26,0),M.Grass,Color3.fromRGB(106,160,74))'
  lp  = 'Vector3.new(0,29,0)'; d = 42
}

# 传送门立在漂浮岛上（单元成果全景）
$U2['2.6-s2'] = @{
  geo = 'P("isle",Vector3.new(28,2,28),Vector3.new(0,26,0),M.Grass,Color3.fromRGB(106,160,74)) CYL("colL",14,3,Vector3.new(-7,34,0),M.Metal,Color3.fromRGB(160,165,170)) CYL("colR",14,3,Vector3.new(7,34,0),M.Metal,Color3.fromRGB(160,165,170)) P("beam",Vector3.new(18,2,3),Vector3.new(0,42,0),M.Metal,Color3.fromRGB(160,165,170)) local c=P("curtain",Vector3.new(12,14,0.6),Vector3.new(0,34,0),M.Neon,Color3.fromRGB(120,80,255),0.4) c.CanCollide=false BALL("orb",4,Vector3.new(11,30,7),M.Neon,Color3.fromRGB(255,210,80))'
  lp  = 'Vector3.new(0,34,0)'; d = 42
}
