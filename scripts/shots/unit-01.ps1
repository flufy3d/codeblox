# ══ 单元 1「走进 Studio」的视口场景 ══════════════════════════════
# 坐标都是场景局部坐标：X 左右、Y 上下、Z 前后，原点在地面。
# 默认斜角 yaw=210（正对 180 + 斜 30），局部 +X 在画面左、-Z 朝镜头。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-01.ps1"
#   Shoot-Batch $U1 'sheet-u1' 2 -Verify
#
# ⚠️ 单元 1 是**重拍**：第一版 20 张是人手动截的英文界面，构图和裁剪都不统一。
#    重拍一律跟单元 2/3 走中文界面。

# ── 世界原点在场景局部坐标里的位置 ────────────────────────────
# 库把场景统一建在 O=(150,0,0)（躲开 SpawnLocation 的太阳贴图），但单元 1 的
# 前两张恰恰**要拍那个 SpawnLocation**（孩子新建 Baseplate 后就是这个画面）。
# base(lp) = CFrame.new(O) * R(yaw) * CFrame.new(lp)，反解 base(lp)=0 得：
#   lp = R(-210°)·(-O) = (129.9, 0, 75)
# 只在默认 yaw=210 下成立 —— 换 yaw 这个常量就不对了。
$W0 = 'Vector3.new(129.9,0,75)'

# ── 《我的迷你乐园》：单元成果场景 ────────────────────────────
# 名字用 PN（真名，会在资源管理器/属性面板里显示给孩子看），所以
# unit-01-ui.ps1 里的树类截图能直接复用这段几何。
# 台阶朝 +Z（远离镜头）一级级升高，读起来就是一段楼梯；发光平台在最高处。
#
# 台阶的「进深」比「升高」大太多就会被拍成一摊平条纹（第一版 4 深 / 2 高 = 27°
# 斜坡，配 20° 俯角几乎正边对镜头）。收到 3.5 深 / 2 高（30°）+ 俯角压到 16°
# 才读得出是一段楼梯。升高保持 2 studs：小人能直接走上去，不用跳。
# ⚠️ 楼梯别贴着地板边缘摆：第一版发光平台在 z=15、地板只到 z=15，一半悬在板外，
#    拍出来像「浮在地板外面」。地板放到 36 见方、整段楼梯往里收，问题就没了。
$PARK = @'
PN("地板",Vector3.new(36,1,36),Vector3.new(0,0.5,0),M.Concrete,Color3.fromRGB(170,170,175))
PN("台阶1",Vector3.new(12,1,3.5),Vector3.new(0,1.5,1),M.Plastic,Color3.fromRGB(235,90,90))
PN("台阶2",Vector3.new(12,1,3.5),Vector3.new(0,3.5,4.5),M.Plastic,Color3.fromRGB(245,195,70))
PN("台阶3",Vector3.new(12,1,3.5),Vector3.new(0,5.5,8),M.Plastic,Color3.fromRGB(110,200,120))
PN("发光平台",Vector3.new(14,1,8),Vector3.new(0,7.5,13),M.Neon,Color3.fromRGB(0,190,255))
'@ -replace "`r?`n", " "

$U1 = [ordered]@{}

# 1.1-s3 · 飞到空中俯视（全新 Baseplate，什么都没建）
# 俯角提到 32° —— config 默认的 20° 是「站在地面看」。
# ⚠️ 别再往上加：视口是 70° 垂直 FOV，俯角超过 35° 画面顶端就低于地平线，
#    天空全没了，Baseplate（2048 见方）铺满整幅 = 一片灰色纹理，什么都读不出。
#    32° + d=110 是「顶上留一线天空、SpawnLocation 在脚下」的甜点。
$U1['1.1-s3'] = @{
  geo = ''
  lp  = $W0; d = 70; pitch = 30
}

# 1.3-s3 · 悬空 + 又长又扁 + 转了角度的平台（Move/Scale/Rotate 三件套的成果）
# 「歪一点点」靠绕 Z 轴 8°，绕 Y 轴 20° 让它跟地板的网格不平行 —— 一眼看出转过。
# 对准点压到平台**上方**（y=11 > 平台 10），地面和影子才会落在画面下半，
# 「浮在半空」才读得出来。
$U1['1.3-s3'] = @{
  geo = 'PN("地板",Vector3.new(30,1,30),Vector3.new(0,0.5,0),M.Concrete,Color3.fromRGB(170,170,175)) local p=PN("平台",Vector3.new(20,1,5),Vector3.new(0,10,0),M.Plastic,Color3.fromRGB(120,180,240)) p.CFrame=p.CFrame*CFrame.Angles(0,math.rad(20),math.rad(12))'
  lp  = 'Vector3.new(0,9,0)'; d = 24
}

# 1.4-s3 · 换成 Neon 材质、亮蓝色的发光方块
$U1['1.4-s3'] = @{
  geo = 'PN("方块",Vector3.new(6,6,6),Vector3.new(0,3,0),M.Neon,Color3.fromRGB(0,190,255))'
  lp  = 'Vector3.new(0,3,0)'; d = 13
}

# 1.7-s1 · 《我的迷你乐园》全景（编辑视角）
# yaw 转到 245（默认 210 再侧 35°）让楼梯横过画面 —— 台阶是「一级级升高」的关系，
# 正对着拍就全叠在一起了。俯角压到 16° 同理。
$U1['1.7-s1'] = @{
  geo = $PARK
  lp  = 'Vector3.new(0,3.5,4)'; d = 32; yaw = 235; pitch = 18
}
