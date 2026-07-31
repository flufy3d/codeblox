# ══ 场景搭建 + 相机对准 ═════════════════════════════════════════
#
# 关键发现（决定了整个设计）：Studio 编辑模式下 CurrentCamera.CFrame 的
# **旋转部分写不进去**，Studio 永远让相机看向自己的一个枢轴点 Q。实测三个
# 不同相机位置的视线精确交于一点，模型成立。
#
# 于是流程是：
#   1) 在对准点放个临时部件、选中它 → 点文档标签把键盘焦点给视口 → 按 F
#      （Studio 的「聚焦选中物」）→ 枢轴 Q 就搬到了对准点
#   2) 把相机摆到  Q − 视线方向 × 距离
#   3) Studio 从这个位置看向 Q，视线方向正好是我指定的俯角/偏航，主体自动居中
#
# 这样俯角、偏航、距离、构图全部确定，不需要试探迭代。

# Lua 公共前缀（只定义函数/常量，不清场）
#   $AimLocal 是这个场景的对准点（局部坐标 Lua 表达式）
function Get-LuaFuncs([string]$AimLocal = 'Vector3.new(0,0,0)', $SceneYaw = $null) {
  $p = $script:CBS.PitchDeg
  $y = $script:CBS.YawDeg
  $so = if ($null -ne $SceneYaw) { $SceneYaw } else { $script:CBS.SceneYawOffsetDeg }
  @"
local ws=workspace local S=game:GetService("Selection") local O=Vector3.new(150,0,0) local M=Enum.Material
local CP=math.rad($p) local CY=math.rad($y)
local LV=Vector3.new(-math.sin(CY)*math.cos(CP),-math.sin(CP),-math.cos(CY)*math.cos(CP))
local YAWC=CFrame.Angles(0,CY+math.rad($so),0)
local AL=$AimLocal
local function base(lp) return CFrame.new(O)*YAWC*CFrame.new(lp) end
local function aimpt() return base(AL).Position end
local function P(n,sz,lp,mat,col,tr) local p=Instance.new("Part") p.Name="CB_"..n p.Size=sz p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.CFrame=base(lp) if mat then p.Material=mat end if col then p.Color=col end if tr then p.Transparency=tr end p.Parent=ws return p end
local function CYL(n,h,dia,lp,mat,col,tr) local p=P(n,Vector3.new(h,dia,dia),lp,mat,col,tr) p.Shape=Enum.PartType.Cylinder p.CFrame=base(lp)*CFrame.Angles(0,0,math.rad(90)) return p end
local function BALL(n,dia,lp,mat,col,tr) local p=P(n,Vector3.new(dia,dia,dia),lp,mat,col,tr) p.Shape=Enum.PartType.Ball return p end
local function MKPIVOT() local old=ws:FindFirstChild("CB_pivot") if old then old:Destroy() end local b=Instance.new("Part") b.Name="CB_pivot" b.Anchored=true b.CanCollide=false b.Transparency=1 b.Size=Vector3.new(1,1,1) b.CFrame=CFrame.new(aimpt()) b.Parent=ws S:Set({b}) end
local function CAM(dist) local old=ws:FindFirstChild("CB_pivot") if old then old:Destroy() end S:Set({}) local cam=ws.CurrentCamera local pos=aimpt()-LV*dist local g=(ws:GetAttribute("CBGEN") or 0)+1 ws:SetAttribute("CBGEN",g) task.spawn(function() for i=1,900 do if ws:GetAttribute("CBGEN")~=g then break end cam.CFrame=CFrame.new(pos) task.wait() end end) end
local function MARK(dist) local old=ws:FindFirstChild("CB_mark") if old then old:Destroy() end local b=Instance.new("Part") b.Name="CB_mark" b.Shape=Enum.PartType.Ball b.Size=Vector3.new(1.6,1.6,1.6) b.Anchored=true b.CanCollide=false b.Material=M.Neon b.Color=Color3.fromRGB(255,0,255) b.CFrame=CFrame.new(aimpt()-LV*(0.35*(dist or 10))) b.Parent=ws end
"@
}

# 清场片段。⚠️ 相机保持循环必须用 Workspace 属性做代数令牌来互斥：
# 早期版本用 os.clock() 计时退出，结果循环根本不退，多个场景的循环互相
# 抢相机，拍出来是随机的哪一个 —— 排查了很久，别再踩。
$script:CB_CLEAR = 'S:Set({}) for _,v in ipairs(ws:GetChildren()) do if v.Name:sub(1,3)=="CB_" then v:Destroy() end end '

# 用 F 键把 Studio 的相机枢轴搬到对准点
function Set-Pivot([string]$AimLocal, $SceneYaw = $null) {
  RunLua ((Get-LuaFuncs $AimLocal $SceneYaw) + " MKPIVOT()") 900
  Focus-Win | Out-Null
  Click $script:CBS.DocTabX $script:CBS.DocTabY 400   # 焦点给视口，不改选择
  Send "f" 900                                        # 聚焦选中物 → 枢轴到位
}

# 建场景 + 对准 + 拍图
#   $GeoLua   建几何的 Lua（用 P/CYL/BALL，坐标是场景局部坐标）
#   $AimLocal 对准点（局部坐标 Lua 表达式，如 'Vector3.new(0,8,0)'）
#   $Dist     相机到对准点的距离
#   $Post     相机摆好之后再跑的 Lua（选中高亮之类会被相机步骤清掉，放这里）
#   $Yaw      单独指定这一张的场景斜角（度），不给就用 config 的默认值
#   -Verify   额外拍一张带品红标记球的图，用程序核对是否真的居中
function Shoot-Scene([string]$GeoLua, [string]$AimLocal, [double]$Dist, [string]$OutName,
                     [string]$Post = '', $Yaw = $null, [switch]$Verify) {
  RunLua ((Get-LuaFuncs $AimLocal $Yaw) + " " + $script:CB_CLEAR + $GeoLua) 1400
  Set-Pivot $AimLocal $Yaw
  RunLua ((Get-LuaFuncs $AimLocal $Yaw) + " CAM($Dist)") 900
  if ($Post) { RunLua ((Get-LuaFuncs $AimLocal $Yaw) + " " + $Post) 800 }
  Start-Sleep -Milliseconds 450
  ShotVP $OutName | Out-Null
  if ($Verify) {
    RunLua ((Get-LuaFuncs $AimLocal $Yaw) + " MARK($Dist)") 800
    Start-Sleep -Milliseconds 300
    ShotVP "_verify" | Out-Null
    $m = Find-Magenta "_verify"
    RunLua 'local b=workspace:FindFirstChild("CB_mark") if b then b:Destroy() end' 600
    if ($m) {
      $ex = $m.X - [int]($script:CBS.VpW/2); $ey = $m.Y - [int]($script:CBS.VpH/2)
      "  {0}: 居中误差 dx={1}px dy={2}px" -f $OutName,$ex,$ey
    } else { "  {0}: 核对失败（标记球被挡住了）" -f $OutName }
  }
}

# 按场景表批量拍。$Table 是 [ordered]@{ '2.1-s3' = @{ geo='...'; lp='...'; d=27 }; ... }
function Shoot-Batch($Table, [string]$SheetName = 'sheet', [int]$Cols = 2, [switch]$Verify) {
  $names = @()
  foreach ($id in $Table.Keys) {
    $n = 'v_' + ($id -replace '\.','_')
    $s = $Table[$id]
    Shoot-Scene $s.geo $s.lp $s.d $n -Post ([string]$s.post) -Yaw $s.yaw -Verify:$Verify
    $names += $n
  }
  ContactSheet $SheetName $names $Cols | Out-Null
  $names
}
