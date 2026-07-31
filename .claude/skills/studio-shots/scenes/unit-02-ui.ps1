# ══ 单元 2 的面板类 / 试玩类截图 ═════════════════════════════════
# 视口类在 unit-02.ps1（一张表批量跑）；这里这 11 张每张的步骤都不一样，
# 所以写成一个个函数。**这是给后续单元照抄的样板**。
#
# 用法：
#   . "...\lib\load.ps1"
#   . "...\scenes\unit-02-ui.ps1"
#   U2-All                    # 全拍一遍
#   U2-Material               # 或者单张重拍
#
# 每张拍完自己 Read 一下 $script:SD\v_2_x-sN.png 核对构图 —— 面板类不像视口类
# 有品红标记球可以程序化验证，只能看图。
#
# ⚠️ 开工前必须确认：属性面板行的 y 坐标（panel.ps1 里的 $PROW）在本机是对的。
#    Props-Top 之后截一张 ShotRegion "_x" "props" 自己量一遍最稳妥。

# 2.1-s1 · Material 下拉展开，框出 Wood
function U2-Material {
  Focus-Win | Out-Null; Send "{ESC}" 400
  Build-Demo 'PN("Part",Vector3.new(6,6,6),Vector3.new(0,3,0))' 'Vector3.new(0,3,0)'
  Aim-Demo 'Vector3.new(0,3,0)' 15
  Select-Named "Part"; Props-Top
  Open-PropDropdown $script:PROW['Material']
  Wheel 1780 420 -4                      # 列表滚到能看见 Wood（每格约 3 行）
  ShotRegion "_mat" "props" | Out-Null
  ReCrop "_mat" "_matBig" 1458 198 452 302 | Out-Null
  Annotate "_matBig" "v_2_1-s1" @( @{ t='box'; x=225; y=254; w=210; h=18 } ) 2
}

# 2.1-s2 · 主页工具栏的「材质」按钮 + 点开后的材质格子
function U2-MaterialButton {
  Focus-Win | Out-Null; Send "{ESC}" 400
  Click 823 103 1200                     # 「材质」按钮右边的下拉箭头
  ShotWin "_tb" | Out-Null
  Crop "_tb" "_tbC" 640 80 440 425 | Out-Null
  Annotate "_tbC" "v_2_1-s2" @( @{ t='box'; x=145; y=5; w=48; h=52 } ) 2
}

# 2.2-s1 · Transparency=0.5 的方块 + 属性面板里那一行（视口和面板同框）
function U2-Transparency {
  Focus-Win | Out-Null; Send "{ESC}" 400
  Build-Demo 'PN("Part",Vector3.new(6,6,6),Vector3.new(0,3,0),M.SmoothPlastic,Color3.fromRGB(120,190,230),0.5)' 'Vector3.new(0,3,0)'
  Aim-Demo 'Vector3.new(0,3,0)' 15
  Select-Named "Part"; Props-Top
  ShotRegion "_tr" "ui" | Out-Null
  Annotate "_tr" "v_2_2-s1" @( @{ t='box'; x=1090; y=220; w=452; h=20 } ) 2
}

# 2.3-s1 · Shape 下拉展开，框出 Cylinder
function U2-Shape {
  Focus-Win | Out-Null; Send "{ESC}" 400
  Build-Demo 'PN("Part",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Concrete)' 'Vector3.new(0,3,0)'
  Aim-Demo 'Vector3.new(0,3,0)' 15
  Select-Named "Part"; Props-Top; Props-Scroll -11
  Open-PropDropdown 507                  # Shape 在「部件」分类下，滚 11 格后落在 y=507
  ShotRegion "_sh" "props" | Out-Null
  ReCrop "_sh" "_shBig" 1458 308 452 312 | Out-Null
  Annotate "_shBig" "v_2_3-s1" @( @{ t='box'; x=225; y=264; w=218; h=18 } ) 2
}

# 2.3-s2 · Size 展开成 X/Y/Z，Y=12，箭头指 Y
function U2-Size {
  Focus-Win | Out-Null; Send "{ESC}" 400
  Build-Demo 'PN("Part",Vector3.new(3,12,3),Vector3.new(0,6,0),M.Concrete)' 'Vector3.new(0,6,0)'
  Aim-Demo 'Vector3.new(0,6,0)' 22
  Select-Named "Part"; Props-Top
  Expand-Prop $script:PROW['Size']
  Click 1530 $script:PROW['ClassName'] 500   # 点个只读行，取消 Size 单元格的编辑态
  ShotRegion "_sz" "props" | Out-Null
  ReCrop "_sz" "_szBig" 1458 596 452 142 | Out-Null
  Annotate "_szBig" "v_2_3-s2" @(
    @{ t='box';   x=8;   y=76;  w=432; h=19 }
    @{ t='arrow'; x1=340; y1=132; x2=262; y2=92 }
  ) 2
}

# 2.4-s1 · CanCollide + Anchored 两行都打勾（分属两个分类，不相邻，各框一个）
function U2-AnchoredCanCollide {
  Focus-Win | Out-Null; Send "{ESC}" 400
  Build-Demo 'PN("Part",Vector3.new(6,6,6),Vector3.new(0,10,0),M.Concrete)' 'Vector3.new(0,10,0)'
  Aim-Demo 'Vector3.new(0,10,0)' 22
  Select-Named "Part"; Props-Top; Props-Scroll -10
  ShotRegion "_ac" "props" | Out-Null
  ReCrop "_ac" "_acBig" 1458 243 452 172 | Out-Null
  Annotate "_acBig" "v_2_4-s1" @(
    @{ t='box'; x=8; y=24;  w=432; h=19 }   # CanCollide（碰撞分类）
    @{ t='box'; x=8; y=147; w=432; h=19 }   # Anchored（部件分类）
  ) 2
}

# 2.4-s2 · CanCollide 没打勾，红圈圈住那个空复选框
function U2-CanCollideOff {
  Focus-Win | Out-Null; Send "{ESC}" 400
  Build-Demo 'local c=PN("光帘",Vector3.new(12,14,0.6),Vector3.new(0,7,0),M.Neon,Color3.fromRGB(120,80,255),0.4) c.CanCollide=false' 'Vector3.new(0,7,0)'
  Aim-Demo 'Vector3.new(0,7,0)' 24
  Select-Named "光帘"; Props-Top; Props-Scroll -10
  ShotRegion "_cc" "props" | Out-Null
  # CanCollide=false 时会多出一行 CanQuery，行位会往下挪 —— 别照搬上面那张的坐标
  ReCrop "_cc" "_ccBig" 1458 243 452 115 | Out-Null
  Annotate "_ccBig" "v_2_4-s2" @( @{ t='ellipse'; x=221; y=17; w=34; h=33 } ) 2
}

# 2.4-s3 · 小人半个身子穿在发光光帘里
# 构图关键：yaw 转到 242（门帘偏侧一点），小人站在门帘平面上（局部 z≈-0.25，
# 往镜头这边挪一点点）。正对着门帘拍完全看不出「半个身子进去」。
function U2-WalkThrough {
  Focus-Win | Out-Null; Send "{ESC}" 400
  $geo = 'local c=PN("光帘",Vector3.new(8,8,0.6),Vector3.new(0,4,0),M.Neon,Color3.fromRGB(120,80,255),0.4) c.CanCollide=false ' + (Rig-At 'Vector3.new(0,0,-0.25)')
  Build-Demo $geo 'Vector3.new(0,3.4,0)' 242
  Aim-Demo 'Vector3.new(0,3.4,0)' 12 242
  RunLua 'game:GetService("Selection"):Set({})' 700
  ShotRegion "v_2_4-s3" "vp"
}

# 2.5-s2 · Ctrl+G 之后 Explorer 里展开的 Model
# 小技巧：Explorer 没有「展开某节点」的 API，但**选中子节点会自动展开父节点**
function U2-ModelTree {
  Focus-Win | Out-Null; Send "{ESC}" 400
  $geo = 'ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|").."Model|") local m=Instance.new("Model") m.Name="Model" m.Parent=ws local function mk(sz,lp) local p=Instance.new("Part") p.Name="Part" p.Anchored=true p.Size=sz p.CFrame=base(lp) p.Material=M.Concrete p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=m end mk(Vector3.new(3,12,3),Vector3.new(-7,6,0)) mk(Vector3.new(3,12,3),Vector3.new(7,6,0)) mk(Vector3.new(18,2,3),Vector3.new(0,13,0))'
  Build-Demo $geo 'Vector3.new(0,7,0)' 192
  Aim-Demo 'Vector3.new(0,7,0)' 26 192
  RunLua 'local m=workspace:FindFirstChild("Model") game:GetService("Selection"):Set(m:GetChildren())' 1000
  ShotRegion "_ex" "explorer" | Out-Null
  ReCrop "_ex" "_exBig" 0 145 362 245 | Out-Null
  Annotate "_exBig" "v_2_5-s2" @( @{ t='box'; x=3; y=130; w=355; h=81 } ) 2
}

# 2.5-s3 · 拱门 + Explorer 里改名成「传送门」（树和视口同框）
function U2-PortalNamed {
  Focus-Win | Out-Null; Send "{ESC}" 400
  $geo = 'ws:SetAttribute("CBX",(ws:GetAttribute("CBX") or "|").."传送门|") local m=Instance.new("Model") m.Name="传送门" m.Parent=ws local function mk(sz,lp) local p=Instance.new("Part") p.Name="Part" p.Anchored=true p.Size=sz p.CFrame=base(lp) p.Material=M.Concrete p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=m end mk(Vector3.new(3,12,3),Vector3.new(-7,6,0)) mk(Vector3.new(3,12,3),Vector3.new(7,6,0)) mk(Vector3.new(18,2,3),Vector3.new(0,13,0))'
  Build-Demo $geo 'Vector3.new(0,7,0)' 192
  Aim-Demo 'Vector3.new(0,7,0)' 26 192
  RunLua 'game:GetService("Selection"):Set({workspace:FindFirstChild("传送门")})' 1000
  ShotRegion "_pn" "left" | Out-Null
  Annotate "_pn" "v_2_5-s3" @( @{ t='box'; x=3; y=130; w=354; h=19 } ) 2
}

# 2.6-s3 · 单元大合照：小人站在漂浮岛上、传送门在身后
function U2-Hero {
  Focus-Win | Out-Null; Send "{ESC}" 400
  $geo = 'P("isle",Vector3.new(28,2,28),Vector3.new(0,26,0),M.Grass,Color3.fromRGB(106,160,74)) CYL("colL",14,3,Vector3.new(-7,34,0),M.Metal,Color3.fromRGB(160,165,170)) CYL("colR",14,3,Vector3.new(7,34,0),M.Metal,Color3.fromRGB(160,165,170)) P("beam",Vector3.new(18,2,3),Vector3.new(0,42,0),M.Metal,Color3.fromRGB(160,165,170)) local c=P("curtain",Vector3.new(12,14,0.6),Vector3.new(0,34,0),M.Neon,Color3.fromRGB(120,80,255),0.4) c.CanCollide=false BALL("orb",3,Vector3.new(10,28.5,1),M.Neon,Color3.fromRGB(255,210,80)) ' + (Rig-At 'Vector3.new(3,27,-7)' 25)
  Build-Demo $geo 'Vector3.new(0,30,0)'
  Aim-Demo 'Vector3.new(0,30,0)' 30
  RunLua 'game:GetService("Selection"):Set({})' 700
  ShotRegion "v_2_6-s3" "vp"
}

function U2-All {
  U2-Material; U2-MaterialButton; U2-Transparency
  U2-Shape; U2-Size
  U2-AnchoredCanCollide; U2-CanCollideOff; U2-WalkThrough
  U2-ModelTree; U2-PortalNamed
  U2-Hero
  "拍完 11 张。逐张 Read $script:SD\v_2_*.png 核对构图，再跑 tools\save-shots.mjs"
}
