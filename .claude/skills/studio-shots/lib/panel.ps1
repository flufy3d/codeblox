# ══ 面板类截图（属性 / 资源管理器 / 工具栏）════════════════════
#
# 视口类截图靠 aim.ps1 全自动；面板类靠**按坐标点 UI**，所以多一步：
# 每次开工先 Props-Top 把属性面板滚到顶，再截一张 Read 一下核对行的 y 坐标
# （下面 $PROW 是本机 1920x1080 实测值，换机器/换 Studio 版本必须重测）。
#
# 已知的两个坑：
#  1) 属性面板的**滚动位置不随选中新部件重置** —— 上一张滚到底了，下一张
#     按 $PROW 的坐标点下去会点到完全不同的行（还可能顺手改掉属性值）。
#     所以每个面板截图都要先 Props-Top。
#  2) 分类不是按字母排的：Anchored 在「部件」分类下，CanCollide 在「碰撞」
#     分类下，中间隔着 CanTouch / AudioCanCollide / CollisionGroup 和一个
#     分类标题 —— 这两行**不挨着**，别照着「相邻两行」去构图。

# 属性面板各行的屏幕 y（面板滚到顶、选中一个普通 Part 时实测）。行距约 23.5px。
$script:PROW = @{
  '外观'=206; 'BrickColor'=231; 'CastShadow'=256; 'Color'=281; 'Material'=305
  'MaterialVariant'=328; 'Reflectance'=351; 'Transparency'=374
  '数据'=399; 'Archivable'=423; 'ClassName'=447; 'Locked'=471; 'Name'=495; 'Parent'=518
  '变换'=610; 'Size'=635; 'CFrame'=658; 'Position'=681; 'Orientation'=704
}

# 属性面板滚到顶 / 滚 N 格（负数向下）
function Props-Top { Focus-Win | Out-Null; Wheel $script:CBS.ParkX 400 25 }
function Props-Scroll([int]$N) { Focus-Win | Out-Null; Wheel $script:CBS.ParkX 400 $N }

# 按名字选中部件（属性面板会显示它）
function Select-Named([string]$Name) {
  RunLua "local p=workspace:FindFirstChild(`"$Name`",true) if p then game:GetService(`"Selection`"):Set({p}) end" 900
}

# 截一张全窗口图并裁出某块区域。$Region: props / explorer / toolbar / ui / vp
function ShotRegion([string]$OutName, [string]$Region = 'props') {
  $c = $script:CBS
  $r = switch ($Region) {
    'props'    { @($c.PropX, $c.PropY, $c.PropW, $c.PropH) }
    'explorer' { @($c.ExpX,  $c.ExpY,  $c.ExpW,  $c.ExpH)  }
    'toolbar'  { @($c.TbX,   $c.TbY,   $c.TbW,   $c.TbH)   }
    'ui'       { @($c.UiX,   $c.UiY,   $c.UiW,   $c.UiH)   }
    'left'     { @($c.LfX,   $c.LfY,   $c.LfW,   $c.LfH)   }
    'vp'       { @($c.VpX,   $c.VpY,   $c.VpW,   $c.VpH)   }
    default    { throw "未知区域: $Region" }
  }
  Move-To $c.ParkX $c.ParkY
  Start-Sleep -Milliseconds 250
  Shot "_full_$OutName" | Out-Null
  Crop "_full_$OutName" $OutName $r[0] $r[1] $r[2] $r[3]
}

# 从上一张全窗口图（_full_<Name>）里再裁一块任意屏幕矩形 —— 不用重新截屏，
# 省一次窗口切换，构图不满意时反复裁很方便
function ReCrop([string]$Name, [string]$OutName, [int]$X, [int]$Y, [int]$W, [int]$H) {
  Crop "_full_$Name" $OutName $X $Y $W $H
}

# 屏幕坐标 → 某个 region 裁剪图内的坐标（画红框时用）
function ToLocal([string]$Region, [int]$X, [int]$Y) {
  $c = $script:CBS
  $o = switch ($Region) {
    'props'    { @($c.PropX, $c.PropY) }
    'explorer' { @($c.ExpX,  $c.ExpY)  }
    'toolbar'  { @($c.TbX,   $c.TbY)   }
    'ui'       { @($c.UiX,   $c.UiY)   }
    'left'     { @($c.LfX,   $c.LfY)   }
    'vp'       { @($c.VpX,   $c.VpY)   }
    default    { throw "未知区域: $Region" }
  }
  [pscustomobject]@{ X = $X - $o[0]; Y = $Y - $o[1] }
}

# 点开一个枚举属性的下拉（Material / Shape 这种）。
# 要点两下：第一下让单元格进编辑态，箭头才出现；第二下点箭头才展开列表。
function Open-PropDropdown([int]$RowY) {
  Focus-Win | Out-Null
  Click $script:CBS.PropValX $RowY 700
  Click $script:CBS.PropArrowX $RowY 1100
}

# 展开 Size / Position 这类复合属性，变成 X / Y / Z 三行
function Expand-Prop([int]$RowY) {
  Focus-Win | Out-Null
  Click $script:CBS.PropExpX $RowY 700
}

# 建一组「给孩子看的」演示部件：名字是真名（Part / 传送门），不带 CB_ 前缀，
# 靠 CBX 属性标记来清场。$GeoLua 里可以用 P / PN / CYL / BALL / base。
function Build-Demo([string]$GeoLua, [string]$AimLocal = 'Vector3.new(0,0,0)', $Yaw = $null, $Pitch = $null) {
  RunLua ((Get-LuaFuncs $AimLocal $Yaw $Pitch) + " " + $script:CB_CLEAR + $GeoLua) 1400
}

# 把相机对准（同 Shoot-Scene 的第 2、3 步，但不截图）
function Aim-Demo([string]$AimLocal, [double]$Dist, $Yaw = $null, $Pitch = $null) {
  Set-Pivot $AimLocal $Yaw $Pitch
  RunLua ((Get-LuaFuncs $AimLocal $Yaw $Pitch) + " CAM($Dist)") 900
}
