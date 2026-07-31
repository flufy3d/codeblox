# ══ studio-shots 配置 ═══════════════════════════════════════════
# 屏幕/窗口相关的坐标全在这里。换分辨率或改 Studio 面板布局后
# 跑 lib\calibrate.ps1 重新量一遍，把新值写回来。

# 中间产物目录（截图、探针图、联络表）。可用环境变量 CBS_OUT 覆盖。
$script:SD = if ($env:CBS_OUT) { $env:CBS_OUT } else { Join-Path $env:TEMP 'codeblox-shots' }
if (-not (Test-Path $script:SD)) { New-Item -ItemType Directory -Path $script:SD | Out-Null }

$script:CBS = @{
  # ── 屏幕坐标（1920x1080、Studio 最大化、资源管理器+属性+输出 三面板都开）──
  CmdBarX   = 400    # 底部命令栏输入框
  CmdBarY   = 989
  RunBtnX   = 1884   # 命令栏右侧「运行」按钮（比 Ctrl+Enter 可靠）
  RunBtnY   = 989
  ParkX     = 1700   # 截图前把鼠标停到这里，避免光标进画面
  ParkY     = 400
  DocTabX   = 413    # 文档标签「Place1」—— 点它能把键盘焦点给 3D 视口
  DocTabY   = 152    # （而不改动当前选择，这样才能按 F 聚焦）

  # 3D 视口矩形（截图裁剪用）。Studio 里 print(cam.ViewportSize) 可核对宽高
  VpX = 367; VpY = 167; VpW = 1086; VpH = 612

  # 输出面板区域（读 print 结果时裁这块）
  LogX = 0; LogY = 845; LogW = 1250; LogH = 135

  # ── 面板类截图（属性 / 资源管理器 / 工具栏）─────────────────
  PropX = 1458; PropY = 145; PropW = 452; PropH = 665   # 属性面板整块
  PropValX   = 1780   # 属性值单元格：点这里进入编辑态
  PropArrowX = 1893   # 枚举属性的下拉箭头（进编辑态后才出现）
  PropExpX   = 1472   # 可展开属性（Size/Position）左侧的小三角
  ExpX = 0; ExpY = 145; ExpW = 362; ExpH = 615          # 资源管理器整块
  TbX = 440; TbY = 80; TbW = 700; TbH = 62              # 主页工具栏那一条
  UiX = 367; UiY = 145; UiW = 1553; UiH = 645           # 视口+属性面板（要同时看到东西和数值时用）
  LfX = 0;   LfY = 145; LfW = 1453; LfH = 645           # 资源管理器+视口（要同时看到树和东西时用）

  # ── 相机 ──────────────────────────────────────────────────
  # Studio 编辑模式下写 CurrentCamera.CFrame **只有位置生效，旋转被忽略**；
  # 它永远看向自己的一个枢轴点 Q。所以做法是先用 F 键把 Q 设到对准点，
  # 再把相机摆到 Q - 视线方向×距离 —— 于是俯角/偏航就完全由下面两个值决定。
  PitchDeg = 20      # 俯角（度，向下为正）。15~25 比较好看
  YawDeg   = 0       # 偏航（度）。0 = 沿 -Z 看

  # 场景相对相机再转多少度，拿到 3/4 斜角构图（180=正对，+30=偏一点）
  SceneYawOffsetDeg = 210

  # 右键拖拽转视角的灵敏度（度/像素），calibrate.ps1 会用到
  DragDegPerPx = 3.1
}
