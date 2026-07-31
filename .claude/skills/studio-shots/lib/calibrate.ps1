# ══ 标定 / 自检 ═════════════════════════════════════════════════
# 换机器或换分辨率后跑一遍。用法（load.ps1 已 dot-source 之后）：
#   . "...\lib\calibrate.ps1"
#   Show-VpProbe      # 核对视口矩形（VpX/VpY/VpW/VpH）
#   Test-Pipeline     # 端到端自检
#   Show-CamState     # 排查用：看 Studio 当前相机朝向
#   Measure-Pivot     # 排查用：解出 Studio 当前的相机枢轴点
#
# 注意：俯角/偏航**不用**标定 —— Shoot-Scene 每张都会用 F 键把枢轴设到
# 对准点，Studio 就必然沿 config 里 PitchDeg/YawDeg 指定的方向看过去。
# 想换角度直接改 config 的数值即可。

# 让 Studio 打印当前相机朝向，然后截输出面板 —— 需要人（或 agent）Read 图片看数字
function Show-CamState {
  Stop-CamHolds | Out-Null          # 先停掉保持循环，否则读到的是自己写进去的值
  Start-Sleep -Seconds 1
  RunLua 'local lv=workspace.CurrentCamera.CFrame.LookVector print("PITCH",math.floor(math.deg(math.asin(-lv.Y))*10)/10,"YAW",math.floor(math.deg(math.atan2(-lv.X,-lv.Z))*10)/10)' 1200
  $p = ShotLog "_camstate"
  "读这张图看 PITCH / YAW: $p"
}

# 解出 Studio 当前的相机枢轴点 Q：从两个相机位置读视线，两条射线的交点就是 Q。
# 正常情况下 Shoot-Scene 会把 Q 设到对准点，这个函数只是排查用。
function Measure-Pivot {
  RunLua 'local ws=workspace local cam=ws.CurrentCamera local out={} ws:SetAttribute("CBGEN",999999) for i,p in ipairs({Vector3.new(150,50,80),Vector3.new(200,50,80)}) do cam.CFrame=CFrame.new(p) task.wait(0.15) local c=cam.CFrame table.insert(out,string.format("P%d pos=%.1f,%.1f,%.1f look=%.4f,%.4f,%.4f",i,c.Position.X,c.Position.Y,c.Position.Z,c.LookVector.X,c.LookVector.Y,c.LookVector.Z)) end task.wait(0.3) for _,s in ipairs(out) do print("PIVOT",s) end' 2500
  $p = ShotLog "_pivot"
  "读这张图，拿两条 pos+look 手算交点即为 Q: $p"
}

# 右键拖拽转视角，灵敏度约 3.1°/px，±90° 会被夹住。
# 平时用不到（角度靠枢轴+config 控制），只在视口被转乱了想手动掰回来时用。
function Nudge-View([int]$Dx = 0, [int]$Dy = 0) {
  $cx = $script:CBS.VpX + [int]($script:CBS.VpW/2)
  $cy = $script:CBS.VpY + [int]($script:CBS.VpH/2)
  Focus-Win | Out-Null
  RDrag ($cx - $Dx) ($cy - $Dy) $cx $cy 20
  Show-CamState
}

# 核对视口矩形：Studio 打印 ViewportSize，应与 config 里的 VpW/VpH 一致；
# 再拍一张全窗口图，人眼确认 VpX/VpY 起点对不对。
function Show-VpProbe {
  RunLua 'print("VIEWPORT",workspace.CurrentCamera.ViewportSize,"FOV",workspace.CurrentCamera.FieldOfView)' 1100
  $a = ShotLog "_vpsize"
  $b = ShotWin "_vpwin"
  "config: VpX=$($script:CBS.VpX) VpY=$($script:CBS.VpY) VpW=$($script:CBS.VpW) VpH=$($script:CBS.VpH)"
  "读这两张: $a  /  $b"
}

# 重测属性面板各行的 y 坐标（panel.ps1 里的 $PROW）。换机器/换 Studio 版本必做：
# 面板类截图全靠按坐标点行，坐标错了会点到别的行、还可能把属性改掉。
function Show-PropRows {
  Build-Demo 'PN("Part",Vector3.new(6,6,6),Vector3.new(0,3,0))' 'Vector3.new(0,3,0)'
  Select-Named "Part"
  Props-Top
  $p = ShotRegion "_prowtop" "props"
  Props-Scroll -10
  $q = ShotRegion "_prowmid" "props"
  "读这两张量行的 y（图内 y + $($script:CBS.PropY) = 屏幕 y）: $p  /  $q"
  "行距约 23.5px；值单元格 x=$($script:CBS.PropValX)，下拉箭头 x=$($script:CBS.PropArrowX)，展开小三角 x=$($script:CBS.PropExpX)"
}

# 端到端自检：建场景 → 设枢轴 → 摆相机 → 截图 → 程序核对居中误差
function Test-Pipeline {
  $geo = 'P("pad",Vector3.new(20,1,20),Vector3.new(0,0,0),M.Slate) local p=P("chk",Vector3.new(2.5,2.5,2.5),Vector3.new(0,10,0),M.Neon,Color3.fromRGB(255,80,80)) p.Shape=Enum.PartType.Ball'
  Shoot-Scene $geo 'Vector3.new(0,10,0)' 30 '_selftest' -Verify
  Mark-Center '_selftest' '_selftest_x' | Out-Null
  "上面的居中误差应在 ±10px 内。再读 $script:SD\_selftest_x.png：红球应压在绿十字上"
}
