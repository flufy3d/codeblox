---
name: studio-shots
description: 在本机自动拍 Roblox Studio 课程配图 —— 用命令栏跑 Lua 搭场景、枢轴法对准相机、截视口/属性面板/资源管理器出图，喂给 npm run shots 的 <Shot> 待拍队列。当任务是「给某单元准备/补拍截图」「自动截图」「配图」「Studio 截图」时使用。需要 Windows + Studio 已打开。
---

# Studio 自动配图

给 CodeBlox 课程拍真实 Studio 截图。人不用动手截图，agent 直接驱动 Studio。

## 能做到什么

**八类都跑通了**，单元 1 的 20 张 + 单元 2 的 18 张 + 单元 3 的 18 张全是这么拍的：

| 类型 | 怎么拍 | 例子 |
|---|---|---|
| 视口（3D 场景） | Lua 搭场景 + 枢轴法对准相机，全自动，居中误差 ±1px | 2.1-s3 / 2.6-s2 |
| 属性面板 | 选中部件 → 滚到目标行 → 按坐标点 → 裁剪 → 画红框 | 2.1-s1 / 2.4-s2 |
| 资源管理器 | 选中**子节点**会自动展开父节点，再裁树 | 2.5-s2 / 3.3-s1 |
| 试玩（小人） | **不进 Play 模式**：编辑模式插一个 Rig 角色，PivotTo 摆位 | 2.4-s3 / 3.7-s3 |
| 代码（脚本编辑器） | 命令栏写 `Script.Source` → 点文档标签 → 裁代码区 | 3.6-s1 / 3.7-s1 |
| 输出面板 | **真按 F5 进 Play 模式**，等脚本 print 出来再裁 | 3.2-s3 / 3.6-s2 |
| 右键菜单 / 弹出列表 | 右键 → 悬停子菜单 → 截图 → 点下去，**必须一次调用内做完** | 3.1-s1 / 3.1-s2 |
| 界面导览（带文字标签） | 全窗口图 + `Annotate` 的 `t='text'` 红底白字标签 | 1.1-s2 |

**起始页那张**（1.1-s1「在模板里选 Baseplate」）拍不到 —— 主窗口已经开着 place，
菜单里也没有「回到起始页」。做法是**再 `Start-Process` 起一个 Studio 实例**（会停在起始页），
按 pid 拿 `MainWindowHandle` 自己 `SetForegroundWindow`（`Focus-Win` 按进程名找，两个实例会认错），
点左侧「模板」→ 截图 → 点右上角 ✕ 关掉那个实例。⚠️ 起始页首屏是「我的近期体验」，
会露出用户自己的作品和账号名，**必须先切到「模板」页再截**。

## 职责边界（别把两边搞混）

- **技能本身**（`.claude/skills/studio-shots/`）只有 `SKILL.md` + `lib/`：可复用的机械部分
  和踩坑经验，跟具体单元无关，不该随单元增长。
- **每个单元的场景定义**放仓库里：`scripts/shots/unit-NN.ps1`（视口类）和
  `scripts/shots/unit-NN-ui.ps1`（面板/试玩类）。这是**用技能的产物**，不是技能的一部分。
- **存图**是仓库的一个 npm 脚本：`scripts/save-shots.mjs` / `npm run shots:save`。

为什么场景定义要留下来而不是拍完就扔：「四种质感地砖怎么摆」这种是按课文写的创作，
没法从工具推出来；留着的价值在**重拍** —— 课文改了、Studio 换版本了、构图不满意了，
改两个数字重跑一遍就行，不用从零复盘。文件是 agent 写的，不用人手写。

`scripts/shots/unit-02*.ps1` 是完整的工作样板，新单元照它抄。
`scripts/shots/unit-03*.ps1` 是加了代码 / 输出 / 弹出菜单三类之后的样板。
`scripts/shots/unit-01*.ps1` 是**重拍**的样板（界面导览、起始页、按钮条、右键改名/打组）。

## 前置条件

1. Roblox Studio 已打开一个 place（有 Baseplate 就行），窗口最大化
2. 屏幕 1920×1080；资源管理器 + 属性 + 输出 三个面板都开着（坐标是按这个布局标的）
3. 底部命令栏可见（「脚本」选项卡 → 命令）
4. 课程里已经写好 `<Shot>` 占位（见 AUTHORING.md），`npm run shots:check` 能列出待拍队列

### Studio 没开的话自己开

```powershell
Start-Process "$env:LOCALAPPDATA\Roblox\Versions\version-*\RobloxStudioBeta.exe"
```

会停在开始页（登录状态还在）。**别去「最近」里开用户的正式作品** —— 点左侧 **模板 →
Baseplate**（第一个）新建一个 Place1。理由不只是安全：单元 3 起有大量资源管理器截图，
全新模板的树只有 `Camera / Terrain / SpawnLocation / Baseplate`，干净得正好，
用户那个 place 里的历史遗留物会直接入镜。

新建的 place **不要 Ctrl+S**（会往用户账号里发东西）。代价是 Rig 不会留下来，
下次得重跑一次 `New-Rig` —— 它已经是全自动的，成本可以忽略。

开完先自检：`Show-VpProbe`（核对视口矩形）+ `Test-Pipeline`（居中误差应在 ±10px 内）。

### 让人能看到进度

Studio 会被反复置前，人就盯不到 agent 在干什么了。**每次工具调用的最后加一句
`Restore-Console`**，把宿主终端弹回来。它靠往上找第一个有窗口的祖先进程来定位终端，
不认死终端名。反过来注意：下一次调用要截图前必须先 `Focus-Win`，否则截到的是终端
（`ShotWin` / `ShotVP` / `ShotRegion` 自己**不会**置前 Studio）。

## 上手

```powershell
. "D:\Projects\CodeBlox\.claude\skills\studio-shots\lib\load.ps1"

# 换机器 / 换分辨率才需要标定（俯角偏航不用标，见下）
. "D:\Projects\CodeBlox\.claude\skills\studio-shots\lib\calibrate.ps1"
Show-VpProbe      # 核对视口矩形
Test-Pipeline     # 端到端自检：居中误差应在 ±10px 内

# 视口类：批量拍一个单元
. "D:\Projects\CodeBlox\scripts\shots\unit-02.ps1"
Shoot-Batch $U2 'sheet-u2' 2 -Verify
# 然后 Read 输出目录里的 sheet-u2.png，一张图检查一整批

# 面板 / 试玩类：照 scripts\shots\unit-02-ui.ps1 的样板写，一张一个函数
. "D:\Projects\CodeBlox\scripts\shots\unit-02-ui.ps1"
U2-All
```

单张调试：`Shoot-Scene $geoLua 'Vector3.new(0,8,0)' 24 'test1' -Verify`

收工：`Clear-Scene`（删掉所有脚本建的部件和相机令牌；**Rig 角色会留着**，下个单元还要用）

## 相机怎么控制的

Studio 编辑模式下写 `CurrentCamera.CFrame` **只有位置生效、旋转被忽略** —— 它永远
让相机看向自己的一个枢轴点 Q（实测三个不同相机位置的视线精确交于一点，模型成立）。
所以每张图的流程是：

1. 在对准点放个透明临时部件并选中 → 点文档标签把键盘焦点给视口 → 按 `F`（聚焦选中物）
   → 枢轴 Q 搬到对准点
2. 把相机摆到 `Q − 视线方向 × 距离`
3. Studio 从这里看向 Q，视线方向正好是 config 里的 `PitchDeg`/`YawDeg`，主体自动居中

换个角度只要改 config 的 `PitchDeg`/`YawDeg`，不用碰视口、不用试探迭代。

## 写视口场景

场景定义放 `scripts/shots/unit-NN.ps1`，格式见 `scripts/shots/unit-02.ps1`。

必填：
- `geo` — 建几何的 Lua，用 `P(名,大小,位置,材质,颜色,透明度)` / `CYL(名,高,直径,位置,...)` /
  `BALL(名,直径,位置,...)` / `PN(...)`。位置是**场景局部坐标**（X 左右、Y 上下、Z 前后，原点在地面）
- `lp` — 对准点（局部坐标），会成为画面正中
- `d` — 相机到对准点的距离。视口 1086×612、FOV 70（垂直），可见高度 ≈ 1.4×d、可见宽度 ≈ 2.5×d，按主体尺寸反推

可选：
- `yaw` — 单独指定这一张的场景斜角（度）。默认 210（=正对 180 + 斜 30）。要读出「两根一样高」
  这种等长关系时用 192 更正对；要看出「穿过一块板子」这种前后关系，反而要转到 240~255 让板子侧过来。
  「一段楼梯一级级升高」也要侧过来（235 左右），正对着拍台阶全叠在一起
- `pitch` — 单独指定这一张的俯角（度），默认 20。要「飞到空中俯视」用 30 左右。
  ⚠️ **别超过 35**：视口垂直 FOV 是 70°，俯角一过 35° 画面顶端就低于地平线，天空全没了，
  Baseplate（2048 见方）铺满整幅 = 一片灰纹理，什么都读不出（1.1-s3 踩过，55° 完全没法用）
- `post` — 相机摆好之后再跑的 Lua。**选中高亮必须放这里** —— 相机步骤会清空选择

`P` 建的部件名字自带 `CB_` 前缀；`PN` 用**真名**（面板标题栏、资源管理器里会显示给孩子看），
名字记在 Workspace 的 `CBX` 属性里供清场识别。属性面板类截图一律用 `PN`。

**局部坐标在画面上的方向**（默认 yaw=210 时）：局部 `+X` 在画面**左**边，局部 `−Z` 是**朝镜头**这一侧。
摆小人、摆装饰球要用到，别猜，记这两条。

构图经验：想体现「浮在半空」，把对准点放到物体**上方**（如岛在 y=26，对准点 y=29），
相机就在岛面之上俯视，地面和影子会落在画面下半 —— 对准点压到物体下方会变成平视看不到顶面。

## 写面板类截图

样板在 `scripts/shots/unit-02-ui.ps1`，每张一个函数。常用积木（`lib/panel.ps1`）：

```powershell
Select-Named "Part"              # 选中部件，属性面板就显示它
Props-Top                        # 属性面板滚到顶（每张都要！见下面的坑）
Props-Scroll -10                 # 往下滚 10 格
Open-PropDropdown $PROW['Material']   # 展开枚举属性的下拉（要点两下，函数里做了）
Expand-Prop $PROW['Size']        # 展开 Size/Position 成 X/Y/Z 三行
ShotRegion "_x" "props"          # 截图并裁出某块：props/explorer/toolbar/ui/left/vp
ReCrop "_x" "_y" 1458 308 452 312     # 从刚才那张全窗口图里再裁一块，不用重新截屏
Annotate "_y" "v_2_3-s1" @( @{t='box'; x=225; y=264; w=218; h=18} ) 2   # 红框/红圈/箭头/文字标签
```

`Annotate` 的 `t='text'`（红底白字小标签）是给「界面导览」那种图标区域用的：
`@{ t='text'; s='① 资源管理器'; x=10; y=700; size=36 }`。**size 至少 30** —— 全窗口图 1920 宽，
网页上要缩到 ~700px，20pt 的字缩完只剩 7px。

`$PROW` 是属性面板各行的屏幕 y 坐标表（本机实测）。**换机器或换 Studio 版本必须重测**：
`Props-Top` 之后 `ShotRegion "_x" "props"`，Read 那张图自己量。

## 写代码类截图

课程从单元 3 开始要拍「代码长什么样」。积木在 `lib/code.ps1`：

```powershell
Set-Code 'workspace.MyPart.Script' @(
  'local part = script.Parent                       -- 找到我住的那个方块'
  'part.Material = Enum.Material.Neon                -- 让它发光'
) -Open
ShotCode "v_3_6-s1" 5 700       # 露出 5 行、宽 700px，行号栏也进画面
```

中文在编辑器里渲染得很好（注释绿、字符串橙、关键字蓝），不用改字体。注释想对齐就
按「**一个汉字算 2 列**」算，统一对到第 51 列。

宽度：网页上 `<Shot>` 是 `w-full`，会把图拉到正文宽度（约 700px）。所以裁窄一点
= 字更大更好认，别为了「完整」裁到 1400px 宽 —— 缩下去孩子就看不清了。
`npm run shots:save` 只缩不放（`withoutEnlargement`），窄图不会被强行放大。

## 写输出面板类截图

**必须真按 F5 进 Play 模式**（`Play-ShotOut`）。命令栏 `print` 出来的行尾是
「- 编辑」，还多一行 `> print(...)` 回显；Play 模式里是「你好，Roblox！ - 服务器 -
Script:1」，跟孩子屏幕上一模一样。红字报错更要 Play：能拿到
`Workspace.MyPart.Script:3: attempt to call a nil value` 加下面三行
`Stack Begin / Line 3 / Stack End`，行号信息全在。

`rig.ps1` 说「不进 Play 模式」针对的是**视口**（F5 之后相机归客户端管，枢轴法失效）。
**只裁输出面板不受影响** —— 面板位置在 Play 模式下不动。

⚠️ Play 模式会跑 Workspace 里**所有**脚本，多留一个就在输出里多一行。所以每张输出图
之前先把别的脚本删干净（`unit-03-ui.ps1` 里的 `U3-NoScripts`）。

## 写试玩类截图

不进 Play 模式。F5 之后相机归客户端管，枢轴法失效，还得用 WASD 把小人开到位 —— 不可控。
改成编辑模式插一个角色模型（`lib/rig.ps1`）：

```powershell
New-Rig                          # 虚拟形象 → 角色 → R15 + 网格虚拟形象(2016)，建一次就够
Prep-Rig                         # 关头顶名字标签 + 上色 + 摆迈步姿势
Build-Demo ($geo + (Rig-At 'Vector3.new(0,0,-0.25)')) 'Vector3.new(0,3.4,0)' 242
```

`Rig-At` 的 `y` 给 0 就是**脚踩地面**（模型枢轴正好在脚底）；给「台阶顶面的高度」就是站在台阶上。
`$TurnDeg` 是相对「面朝镜头」再转多少度：0 = 正对镜头，180 = 背对。

**Rig 建好上过色就别再 `Prep-Rig`** —— 摆姿势是往 Motor6D 的 `C0` 上**累乘**，再跑一次腿就掰过头了。
判断依据：`Head.Color` 是 `1, 0.8, 0.4` 就说明上过色、也摆过姿势了。

**拍资源管理器之前 `Stash-Rig`**（搬去 ServerStorage），拍完 `Unstash-Rig`。`Park-Rig` 只把它挪出镜头，
树上照样露着一个 `Rig` 节点 —— 孩子的 Workspace 里没这东西，图就对不上。删了再 `New-Rig` 又慢又容易失败。

默认那个灰扑扑的骨架拍出来很闷，`Prep-Rig` 上完色（黄皮肤 + 蓝上衣 + 深蓝裤子）就是标准
Roblox 小人的样子，画面立刻好看很多 —— 别省这一步。

## 出图存进 public/shots

截出来的是 PNG，在 `$env:TEMP\codeblox-shots\`。在**仓库根目录**跑：

```bash
npm run shots:save -- --dry     # 先看要存哪些
npm run shots:save              # 真存
npm run shots:check             # 确认待拍数减少了
```

源目录默认就是技能的输出目录，不用传。只存某几张：`npm run shots:save -- 2.1-s3 2.6-s1`。

自动把 `v_2_1-s3.png` 映射成 `public/shots/2.1-s3.webp`，参数和截图控制台一致（最长边
1600、webp q90），实测 500KB PNG → 20~26KB webp。课程里没有对应 `<Shot>` 的 id 会被跳过，
不会产生孤儿图。

用的是 `sharp`（astro 的**间接**依赖）。哪天依赖升级把它弄丢了，退路是截图控制台：
`npm run shots` 开着 → `Set-Clipboard -Path <png>` → 切到控制台标签 → `Ctrl+V` → `Enter`
（会按待拍队列顺序存，所以必须按 `shots:check` 打印的顺序逐张粘）。

看成果：**dev server 用 `localhost:4321`**（不是 127.0.0.1，astro 没绑那个 host）。
截图控制台 `127.0.0.1:4444` 只列**待拍**的，而且不会自动刷新，别拿它当成果页看。

## 已知坑（都踩过，别重复）

**右键菜单 / 弹出列表一换工具调用就没了**。每次 PowerShell 调用开头的 `Focus-Win`（`SetForegroundWindow`）会让弹出层失焦、自动收起。所以「右键 → 悬停子菜单 → 截图 → 点某项」这一串**必须写在同一个函数里**，中间不能拆成两次工具调用去看中间结果。子菜单用 `Move-To` 悬停 + `Start-Sleep`，比 `Click` 稳。

**资源管理器行尾那个「+」会把右键吃掉**。鼠标悬停在某一行时，行名右边会冒出一个圆形「＋」快捷插入按钮；右键**正好点在它上面时菜单根本不弹**，而且完全不报错 —— 排查了很久（连试了「窗口没真激活」「要先点文档标签」几个方向都不对）。所以右键树节点时 x 要**靠左压在图标/文字上**（`x=58` 稳）。单元 3 用 `x=73` 右键 `Workspace` 能成，纯粹是因为这行字长、「＋」被顶得更右。

**右键菜单的项数随「选中几个」变**。多选时没有「重命名」（不能一次给三个东西改名），它**后面所有项整体上移一行（22px）**。所以偏移表要按单选/多选分两套记（`unit-01-ui.ps1` 里的 `$U1MENU` / `$U1MENUM`）—— 拿单选量出来的坐标去点多选菜单，会点到隔壁那项（我第一次把红框画到了「作为文件夹分组」上）。

**资源管理器里双击改不了名**。当前 Studio 双击树节点没反应（不进改名态），紧接着的 `Ctrl+A` 会**把整棵树全选中**，很危险。改名要走**右键 → 重命名**。课文里「双击方块的名字」那句话也是错的，已改。

**`Color` 属性行点开没有色板**。它只是变成一个可编辑的 `163, 162, 165` 文本格（要再点值左边的小色块才弹取色器）。想拍「挑颜色」，用**主页 → 颜色** 那块六边形色板，比属性面板直观得多。

**改完名字要把新名字补进 `CBX`**。`PN("Part")` 把 `Part` 记进了 Workspace 的 `CBX` 清单，之后在界面上把它改名成「地板」，`Clear-Scene` 就认不出它了 —— 这个部件会永远留在 place 里。改名后补一句 `ws:SetAttribute("CBX", ... .."地板|")`。

**写 `Script.Source` 有两个前提**。① 别写成 `s.Source="第一行\n第二行"` —— 源码里本来就有双引号（`print("x")`），会把外层字符串提前闭合，报 `Expected identifier when parsing expression, got Unicode character U+4f60`（U+4F60 是「你」，因为它紧跟在被提前闭合的引号后面）。正解是每行用 Lua 长括号 `[[...]]` 包起来再 `table.concat(...,"\n")`。② 文档**已经在编辑器里打开**时写 `Source` 完全不生效，也不报错，画面上还是旧代码 —— 打开的 `ScriptDocument` 占着缓冲区。要先 `ScriptEditorService:FindScriptDocument(s)` 然后 `doc:CloseAsync()`。这两条 `Set-Code` 都替你处理了。

**`LogService:ClearOutput()` 连命令自己的回显一起清掉**。回显是提交时写进去的，比 `ClearOutput()` 早，所以把它放在**同一条命令的最后**就能得到一块全空的输出面板 —— 这正是 Play 模式截图前想要的状态。

**资源管理器的排序不是创建顺序，也不是字母序**。`Camera` / `Terrain` 钉在最前，后面既不按插入顺序也不按字母（实测 `Script`(265) → `SpawnLocation`(285) → `Baseplate`(305)）。行高 20px。**每次插完东西先 `ShotWin` 看一眼真实行位**，别照抄别的单元的 y 坐标。

**`New-Rig` 的等待时间别往下调**。切标签页 + 弹对话框 + 网格虚拟形象联网拉资源都要时间，短了就「RIG 没建出来」。实测 900/1500/2500 失败、1500/2500/5000 成功。另外建 Rig 会在树里多一个 `Rig` 节点，**资源管理器类的图要在 `New-Rig` 之前拍完**，否则孩子的树里没有它、图就对不上。

**一排东西越长，斜角就得越小、距离越远**。5 个方块排一排时 yaw=195（偏 15°）会让这排在深度上前后差 10 studs，最近那块被透视放大到出画面 —— 收到 188 就好了。「色卡」「等长对比」这类图本来就该接近正对。

**AMSI 会拦脚本**。截屏 + 模拟鼠标键盘 + 窗口置前写在同一个 .ps1 里，Windows Defender 会判成 RAT 特征直接拒绝加载（报 `This script contains malicious content`）。所以 `cap.ps1`（截屏/画图）和 `win.ps1`（输入）**必须分开**。另外别在任何文件里写 `GetAsyncKeyState` —— 键盘记录器特征，一加就被拦。

**别用 SendKeys 打字**。中文输入法会把空格当上屏键吃掉，还会乱改大小写（`hello from claude` → `hellofromClaude`）。所有文本走剪贴板 + `Ctrl+V`。

**命令栏用「运行」按钮触发，别用 Ctrl+Enter**。后者会偶发不生效；两个都发则命令执行两次。

**旋转写不进去，读回来的值会骗你**。`cam.CFrame = ...` 之后读 `cam.CFrame` 拿到的是你自己写进去的值（旋转也在），但渲染用的是 Studio 自己的朝向。所以「读值验证通过」不代表画面对了 —— 只能看截图。排查这个绕了很久：两个相差 100° 的俯角渲染出完全一样的画面，才确认旋转根本没生效。

**别试图用公式一步算准构图，也别用「每帧重读朝向再重算位置」**。前者算出来能差 100+ 像素（因为 Studio 在按枢轴重新对准）；后者会形成正反馈，几秒内相机就跑成纯俯视。正解是上面的枢轴法：先用 `F` 把枢轴钉到对准点，再摆位置。

**相机保持循环必须互斥**。Studio 会持续把相机拽回去，所以要开个 `task.spawn` 循环每帧写位置。早期版本用 `os.clock()` 计时退出 —— 循环根本不退，每个场景的循环互相抢相机，拍出来是随机的哪一个，排查了很久。现在用 `workspace:SetAttribute("CBGEN", n)` 做代数令牌：新循环抬号，旧循环发现号变了就自己退。

**场景别建在原点**。SpawnLocation 那个太阳贴图会挡镜。库里统一建在 `O = (150,0,0)`，仍在 Baseplate 上。

**首次跑 Lua 会弹「Dangerous Command Detected」**（因为碰了 CurrentCamera）。点 **Always Continue** 免得每张都拦一次 —— 这会改 Studio 的一个提示偏好。

**属性面板的滚动位置不随选中新部件重置**。上一张滚到底了，下一张按 `$PROW` 的坐标点下去会点到完全不同的行 —— 而且可能顺手把某个属性**改掉**（我第一次就把 Anchored 的勾点没了）。所以每个面板截图开头都要 `Props-Top`。

**Anchored 和 CanCollide 不相邻**。属性面板不是按字母排的，是按分类：`Anchored` 在「部件」下，`CanCollide` 在「碰撞」下，中间隔着 CanTouch / AudioCanCollide / CollisionGroup 和一个分类标题。课程里写「两行挨在一起」的地方要改。另外 `CanCollide=false` 时会**多出一行 CanQuery**，行位整体下移 —— 别把两张图的裁剪坐标混用。

**清场标记别打在部件身上**。早期版本给演示部件加 `CBX` 属性做标记，结果属性面板底部的「属性」分类把它显示出来，直接入镜。现在名字记在 Workspace 的 `CBX` 属性里。

**`Wheel` 的 dwData 必须是 `int` 不能是 `uint`**。向下滚是 -120，声明成 uint 会溢出报错 —— 这个 bug 藏了很久，因为之前从没往下滚过。

**资源管理器没有「展开节点」的 API**，但 `Selection:Set({子节点})` 会自动把父节点展开。要展开的 Model 就选它的 children。

## 界面语言

全部走**中文界面**（用户拍板：中文反而跟孩子自己屏幕上看到的一致）。
Unit 1 最早那 20 张是人手动截的英文界面、构图也不统一，2026-08 已全部重拍成中文。

**顺手核对课文里的菜单路径**：课程是照着老版本 Studio 写的，好几处对不上当前中文界面。
拍图时看到就改（这是拍图的一部分，不是额外任务）。核对过的完整清单在 `AUTHORING.md` 第 5 节，
最容易踩的几条：

| 课文原来写的 | 当前中文界面实际是 |
|---|---|
| View（视图）选项卡 → Output | **没有「视图」ribbon 选项卡**。输出 / 命令栏在**「脚本」选项卡**里 |
| View（视图）选项卡 → Explorer / Properties | 资源管理器 / 属性 在**「主页」选项卡**最右边 |
| Home → Insert → Part | **主页 → 部件**（点小箭头才展开方块/球体/楔形/圆柱） |
| 右键 → Insert Object → Script | 右键 → **插入 → 插入对象…**，再在搜索框里搜 Script |
| 右键 → Insert Object → Part | 右键 → **插入 → 插入部件**（直接一步，不用搜） |
| 双击名字改名 | 右键 → **重命名**（双击不进改名态） |
| 右键 → Group | 右键 → **作为模型分组**（ribbon 上那个按钮叫「群组」） |
| 顶部中间的 ▶️ Play | ▶️ 在**左上角** |
| Model（模型）选项卡开网格吸附 | 主页选项卡上的 **☑ 1 格 / ☑ 45°** 两个勾勾 |

⚠️ 单元 2、4~7 里还有同样的错（`grep -n 'View（视图）\|Insert Object' src/content/lessons`），
单元 1、3 已改。别顺手全改掉 —— 那是几十处、跨已发布单元的改动，先问用户。
