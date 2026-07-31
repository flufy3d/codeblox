# ══ 小人（角色）══════════════════════════════════════════════════
#
# 「试玩中小人正在……」这类图**不用真的进 Play 模式**。F5 之后相机归客户端
# 管，我们那套枢轴对准法就失效了，还得靠 WASD 把小人开到位 —— 不可控。
#
# 做法：用 Studio 自带的「绑定生成器」在**编辑模式**插一个角色模型（名字叫
# Rig），然后用 PivotTo 精确摆位。编辑模式不跑物理，摆哪儿待哪儿。渲染出来
# 跟真试玩的画面没区别（少了血条/聊天那层 UI，对课程配图反而更干净）。
#
# Rig 建一次就能一直用：Clear-Scene 不会删它（不带 CB_ 前缀、也不在 CBX 名单里）。

# 插一个 R15 网格角色。菜单路径：虚拟形象 → 角色 → R15 + 网格虚拟形象(2016)
# 坐标是 1920x1080 实测；对话框长得不一样就先 ShotWin 看一眼再改。
#
# ⚠️ 等待时间别再往下调：短了会「RIG 没建出来」（标签页切换 + 对话框弹出 + 网格
#    虚拟形象要联网拉资源，都得时间）。踩过一次 900/1500/2500 失败、1500/2500/5000 成功。
# ⚠️ 建 Rig 会在 Workspace 树里多出一个「Rig」节点。**资源管理器类的截图要在
#    New-Rig 之前拍完** —— 否则孩子的树里没有 Rig，图就对不上了。
function New-Rig {
  Focus-Win | Out-Null
  Click 791 63  1500    # 「虚拟形象」标签页
  Click 548 108 2500    # 「角色」按钮 → 弹出「生成骨架」对话框
  Click 830 330 600     # 骨架类型 R15
  Click 909 653 5000    # 网格虚拟形象 (2016)
  Click 708 63  800     # 切回「主页」标签页
  RunLua 'local r=workspace:FindFirstChild("Rig") print(r and ("RIG OK "..tostring(r:GetPivot().Position)) or "RIG 没建出来")' 1200
}

# 出镜前的整理：关掉头顶名字标签、上色、摆个迈步姿势。
# 默认那个灰扑扑的骨架拍出来很闷，上色后就是标准 Roblox 小人的样子。
function Prep-Rig([switch]$NoPose) {
  RunLua 'local r=workspace:FindFirstChild("Rig") local h=r:FindFirstChildOfClass("Humanoid") h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None h.NameDisplayDistance=0 h.HealthDisplayDistance=0 local skin=Color3.fromRGB(255,204,102) local shirt=Color3.fromRGB(0,150,220) local pants=Color3.fromRGB(60,75,140) local map={Head=skin,UpperTorso=shirt,LowerTorso=shirt,LeftUpperArm=skin,LeftLowerArm=skin,LeftHand=skin,RightUpperArm=skin,RightLowerArm=skin,RightHand=skin,LeftUpperLeg=pants,LeftLowerLeg=pants,LeftFoot=pants,RightUpperLeg=pants,RightLowerLeg=pants,RightFoot=pants} for n,c in pairs(map) do local p=r:FindFirstChild(n) if p then p.Color=c end end print("rig prepped")' 1300
  if (-not $NoPose) {
    # 改 Motor6D 的 C0 就能摆姿势，编辑模式下立刻生效（动画编辑器就是这么干的）
    RunLua 'local r=workspace:FindFirstChild("Rig") local function rot(part,motor,dx) local m=r:FindFirstChild(part) if m then local j=m:FindFirstChild(motor) if j then j.C0=j.C0*CFrame.Angles(math.rad(dx),0,0) end end end rot("LeftUpperLeg","LeftHip",-28) rot("RightUpperLeg","RightHip",28) rot("LeftLowerLeg","LeftKnee",18) rot("LeftUpperArm","LeftShoulder",25) rot("RightUpperArm","RightShoulder",-25) print("posed")' 1200
  }
}

# 摆位用的 Lua 片段，拼进 Build-Demo 的 geo 里。
#   $Lp    场景局部坐标；**y 给 0 就是脚踩地面**（模型枢轴就在脚底）
#   $TurnDeg  相对「面朝镜头」再转多少度。0 = 正对镜头，180 = 背对镜头
# 注意：局部 -Z 是朝镜头那一侧，局部 +X 在画面**左**边（被 SceneYawOffset 转过）。
function Rig-At([string]$Lp, [double]$TurnDeg = 0) {
  "local r=ws:FindFirstChild(`"Rig`") if r then r:PivotTo(base($Lp)*CFrame.Angles(0,math.rad($TurnDeg),0)) end "
}

# 拍完把小人挪出镜头（不删，下个单元还要用）。
# ⚠️ 挪到地图**底下**去，别挪到 (0,0,0) —— 那儿离场景原点 (150,0,0) 不算远，
#    广角一点的构图照样会把它拍进去（踩过）。
function Park-Rig { RunLua 'local r=workspace:FindFirstChild("Rig") if r then r:PivotTo(CFrame.new(0,-400,0)) end' 800 }
