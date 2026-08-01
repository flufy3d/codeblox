# ══ 单元 8 的弹窗 / 起始页 / 网站截图 ══════════════════════════
# 这个单元**一张视口图都没有**（所以没有 unit-08.ps1）：17 张全是「界面长什么样」——
# 文件菜单、保存/发布弹窗、体验设置、起始页、以及 Roblox 创作者中心的网页。
#
# 用法：
#   . ".claude\skills\studio-shots\lib\load.ps1"
#   . "scripts\shots\unit-08-ui.ps1"
#   U8-Menus          # 不落地的那几张，随时能重跑
#   U8-Web            # 网页那 6 张（要先手动把 Chrome 开到对应页面，见下）
#
# ⚠️⚠️ 这个单元跟前七个单元有一条**本质区别**：它教的操作**会真的往用户的 Roblox
#    账号里写东西**。8.1 要「保存至 Roblox」、8.2 要「发布至 Roblox」、8.3/8.5 要拍
#    创作者中心里那个体验的页面 —— 这些都拍不了假的。
#
#    2026-08 那一轮是**问过用户之后**做的：在账号里建了一个一次性的示范体验
#    「我的障碍跑酷」（描述：一个会变色的跳跳乐园，小心熔岩！），拍完由用户决定
#    归档还是删除。**重拍前必须再问一次**，别自己按这个脚本往账号里发东西。
#    真要重来，最省事的是让用户先在创作者中心新建/保留一个私人体验给你拍。
#
# ⚠️ 用户名可以出现在图里（跟单元 6 一致，用户拍板）。但**列表类的界面只裁示范
#    作品那一块** —— 起始页的「体验」页、创作者中心的「作品」页都会把用户自己的
#    真实作品一起列出来，裁宽了就把别人的东西发上 GitHub Pages 了。下面每个
#    Crop 的宽度都是按「刚好切在第二张卡片左边」算的，别随手加宽。

# ── 屏幕坐标（本机 1920x1080、Studio 最大化，实测）─────────────
$U8FILE  = @{ X = 20;  Y = 35 }                       # 菜单栏「文件」
$U8ROW   = @{ SaveFile = 282; SaveAs = 304; SaveRbx = 326; SaveRbxAs = 348
              PubRbx = 380; PubRbxAs = 402; GameSettings = 432 }   # 文件菜单各行的屏幕 y
$U8DLG   = @{ X = 483; Y = 143; W = 957; H = 748 }    # 保存体验 / 发布体验 窗口
$U8DLGB  = @{ CancelX = 1191; OkX = 1341; Y = 858 }   # 那两个窗口底部的 取消 / 保存|创建
$U8GSB   = @{ CancelX = 1191; OkX = 1341; Y = 798 }   # 体验设置窗口底部（比上面高 60px！）
$U8NAME  = @{ X = 1150; Y = 247 }                     # 名称输入框
$U8DESC  = @{ X = 1150; Y = 337 }                     # 描述输入框
$U8TC    = @{ X = 908;  Y = 589 }                     # 组队创作 开关（保存体验窗口里）
$U8DS    = @{ X = 908;  Y = 664 }                     # 数据分享 开关
$U8GSNAV = @{ X = 577; Basic = 257; Comm = 301; Sec = 344; Other = 387 }  # 体验设置左侧四项
$U8COLLAB= @{ X = 1691; Y = 63 }                      # 右上角「协作」（团队创作开着时的位置）

# ── 8.1-s1 / 8.2-s1：文件菜单里的四行 ─────────────────────────
# 一次截图裁两张：8.1 框两个「保存」，8.2 框「发布至 Roblox」。
# 菜单宽度只有 232px，裁到 420 是为了把标题栏和菜单栏一起带进画面 —— 光一条
# 窄菜单在网页上被拉到 700 宽会糊，而且孩子认不出这是 Studio 的哪儿。
function U8-Menus {
  Focus-Win | Out-Null
  Click $U8FILE.X $U8FILE.Y 700
  Shot "_u8file" | Out-Null
  Send "{ESC}" 400
  Crop "_u8file" "_c81s1" 0 0 420 420 | Out-Null
  Annotate "_c81s1" "v_8_1-s1" @(
    @{ t='box'; x=8; y=($U8ROW.SaveFile - 11); w=224; h=22 }
    @{ t='box'; x=8; y=($U8ROW.SaveRbx  - 11); w=224; h=22 }
  ) 3 | Out-Null
  Crop "_u8file" "_c82s1" 0 0 420 420 | Out-Null
  Annotate "_c82s1" "v_8_2-s1" @( @{ t='box'; x=8; y=($U8ROW.PubRbx - 11); w=224; h=22 } ) 3
}

# ── 8.1-s2 / 8.1-s3：保存体验弹窗（不点保存）──────────────────
# Ctrl+S 在**没保存至 Roblox 过**的 place 上弹「保存体验」；已经绑过云端的 place
# 按下去是直接存，不弹窗（那时想重拍就先 文件 → 新增 开一个干净的 Place1）。
# 上下两半分开裁：整窗 957x748 缩到正文宽 700 之后字只有 10px，切成两张才看得清。
function U8-SaveDlg {
  Focus-Win | Out-Null
  Send "^s" 2600
  Click $U8NAME.X $U8NAME.Y 400; Send "^a" 200
  Set-Clipboard "我的障碍跑酷"; Send "^v" 500
  Click $U8DESC.X $U8DESC.Y 400
  Set-Clipboard "一个会变色的跳跳乐园，小心熔岩！"; Send "^v" 500
  Move-To 1700 400; Start-Sleep -Milliseconds 400
  Shot "_u8save" | Out-Null
  Crop "_u8save" "_c81s2" $U8DLG.X $U8DLG.Y $U8DLG.W 420 | Out-Null
  Annotate "_c81s2" "v_8_1-s2" @(
    @{ t='box'; x=394; y=88;  w=553; h=32 }
    @{ t='box'; x=394; y=160; w=553; h=68 }
  ) 3 | Out-Null
  # 下半张要的是**两个开关默认都开着（绿色）**的样子 —— 课文的家长提示就指这个
  Crop "_u8save" "_c81s3" $U8DLG.X 555 $U8DLG.W 333 | Out-Null
  Annotate "_c81s3" "v_8_1-s3" @(
    @{ t='box'; x=395; y=18; w=60; h=32 }
    @{ t='box'; x=395; y=93; w=60; h=32 }
  ) 3 | Out-Null
  "拍完。窗口还开着：Click $($U8DLGB.CancelX) $($U8DLGB.Y) 取消，或 U8-DoSave 真的存上云"
}

# ── 8.1-s4：真的点「保存」，拍「保存成功！」──────────────────
# ⚠️ 这一步会在用户账号里**创建一个体验**。跑之前先问用户。
# 拍出来的图里那张缩略图是 Roblox 给的占位图（西部小镇），不是你的场景。
function U8-DoSave {
  param([switch]$Yes)
  if (-not $Yes) { return "⚠️ 这会往用户的 Roblox 账号里建一个体验。确认过就加 -Yes 再跑。" }
  Focus-Win | Out-Null
  Click $U8TC.X $U8TC.Y 500        # 组队创作 → 关（对示范体验来说没必要开着云端协作）
  Click $U8DS.X $U8DS.Y 500        # 数据分享 → 关（课文自己就在提醒家长关掉它）
  Click $U8DLGB.OkX $U8DLGB.Y 1000
  Start-Sleep -Seconds 8
  Shot "_u8saved" | Out-Null
  Crop "_u8saved" "_c81s4" $U8DLG.X $U8DLG.Y $U8DLG.W 430 | Out-Null
  Annotate "_c81s4" "v_8_1-s4" @( @{ t='box'; x=420; y=303; w=120; h=28 } ) 3 | Out-Null
  Click 960 819 1200               # 关闭
  "标题栏应该已经变成体验名了：$((Get-Process RobloxStudioBeta).MainWindowTitle)"
}

# ── 8.2-s3：发布体验弹窗（跟保存体验长一样，按钮是「创建」）───
# 只有**从没保存至 Roblox 过**的 place 按 Alt+P 才会看到它。拍完一定 取消。
function U8-PublishDlg {
  Focus-Win | Out-Null
  Send "%p" 3000
  Shot "_u8pubdlg" | Out-Null
  Crop "_u8pubdlg" "_c82s3" $U8DLG.X $U8DLG.Y $U8DLG.W $U8DLG.H | Out-Null
  Annotate "_c82s3" "v_8_2-s3" @(
    @{ t='box'; x=22;  y=3;   w=100; h=24 }    # 标题「发布体验」
    @{ t='box'; x=796; y=699; w=126; h=34 }    # 右下角「创建」
  ) 3 | Out-Null
  Click $U8DLGB.CancelX $U8DLGB.Y 800
  "已取消，没有发布"
}

# ── 8.2-s2：真的发布，拍输出面板里那行「已将…发布至 Roblox」───
# ⚠️ 实机关键事实（课文按这个改过）：place **已经保存至 Roblox 之后**，Alt+P
#    **不弹任何窗口**，一两秒就发完，唯一的反馈是输出面板里的一行字 + 四条蓝色
#    快速链接（添加发布说明 / 编辑体验详情和受众 / 查看表现 / 查看错误报告）。
function U8-DoPublish {
  param([switch]$Yes)
  if (-not $Yes) { return "⚠️ 这会把当前 place 发布上线。确认过就加 -Yes 再跑。" }
  Focus-Win | Out-Null
  Send "%p" 4000
  Move-To 1700 400; Start-Sleep -Milliseconds 400
  Shot "_u8pub" | Out-Null
  # 输出面板：连「输出」标题栏和筛选行一起留着，不然一片白认不出是哪个窗口
  Crop "_u8pub" "_c82s2" 0 790 1010 175 | Out-Null
  Annotate "_c82s2" "v_8_2-s2" @( @{ t='box'; x=125; y=50; w=290; h=22 } ) 3
}

# ── 8.3-s1：体验设置 → 其他设置（Studio 里改不了隐私）─────────
# 实机核对：体验设置 只有 基础信息 / 通讯 / 安全 / 其他设置 四页，**没有**任何
# 「隐私 / 权限 / 受众」的开关。其他设置页自己写着「有关其他设置，请参见创作者
# 中心」，并给出「受众 · 访问权限」链接 —— 这就是 8.3 必须去网站的实机依据。
# ⚠️ place 没保存至 Roblox 过时，这个窗口只有一句「保存以访问体验设置」+ 一个按钮。
function U8-GameSettings {
  Focus-Win | Out-Null
  Click $U8FILE.X $U8FILE.Y 600
  Click 60 $U8ROW.GameSettings 3500
  Click $U8GSNAV.X $U8GSNAV.Other 1200
  Shot "_u8gs" | Out-Null
  Crop "_u8gs" "_m_other" $U8DLG.X 200 $U8DLG.W 620 | Out-Null
  Annotate "_m_other" "v_8_3-s1" @(
    @{ t='box'; x=212; y=135; w=114; h=23 }    # 受众 · 访问权限
    @{ t='box'; x=8;   y=589; w=126; h=23 }    # 在创作者中心管理
  ) 3 | Out-Null
  Click $U8GSB.CancelX $U8GSB.Y 800
  "已取消"
}

# ── 8.4-s1 / 8.4-s2：协作按钮 + 管理协作者 ────────────────────
# 8.4 原来的课文（「加为好友 / 给好友访问权限」）实机根本不存在，已重写。真实情况：
#  · 受众=私人 的体验，Roblox 的原话是「只有所有者和拥有编辑权限的人才能游玩」——
#    朋友拿到链接进不去。
#  · 唯一能放特定人进来的正路是**协作者**：Studio 右上角「协作」→ 管理协作者 →
#    在「添加用户和群组」里搜对方用户名。给出去的是**编辑权限**。
#  · 创作者中心的「权限 → 协作者」页在本机账号上只显示「无合作人」，**没有添加
#    入口**（团队创作开着也一样）—— 所以课文教 Studio 这条路，不教网站那条。
#  · 「协作」按钮的 x 会随团队创作开/关变（关着时约 1737、开着时约 1691，因为开着
#    会多出一个参与者头像）。8.4-s1 用的是**关着**那一版（孩子屏幕上的常态）。
function U8-Collab {
  Focus-Win | Out-Null
  Shot "_u8top" | Out-Null
  Crop "_u8top" "_c84a" 1560 40 360 56 | Out-Null
  Annotate "_c84a" "v_8_4-s1" @( @{ t='box'; x=150; y=10; w=68; h=34 } ) 3 | Out-Null
  Click $U8COLLAB.X $U8COLLAB.Y 2500
  Shot "_u8collab" | Out-Null
  Crop "_u8collab" "_c84b" 560 215 800 195 | Out-Null
  Annotate "_c84b" "v_8_4-s2" @( @{ t='box'; x=14; y=63; w=772; h=36 } ) 3 | Out-Null
  Click 1257 787 800     # 取消
  "已取消，没有加任何人"
}

# ── 8.1-s5：起始页的「体验」页 ────────────────────────────────
# 主窗口已经开着 place，菜单里也没有「回到起始页」，所以**再起一个 Studio 实例**
# （会停在起始页），按 pid 拿 MainWindowHandle 自己置前 —— Focus-Win 按进程名找，
# 两个实例会认错。拍完点右上角 ✕ 关掉那个实例。
# ⚠️ 起始页首屏是「我的近期体验」，会把用户所有作品和账号名一起列出来。切到左侧
#    「体验」页之后，裁剪宽度**卡在 460**（第二张卡片从 465 开始），只留示范那一张。
function U8-StartPage {
  $exe = (Get-Item "$env:LOCALAPPDATA\Roblox\Versions\version-*\RobloxStudioBeta.exe" | Select-Object -First 1).FullName
  $p = Start-Process $exe -PassThru
  Start-Sleep -Seconds 18
  $p.Refresh()
  if ($p.MainWindowHandle -eq 0) { return "起始页实例没起来，重跑一次" }
  [Nw]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
  Start-Sleep -Seconds 2
  Click 72 342 3000              # 左侧「体验」
  Move-To 1700 900; Start-Sleep -Milliseconds 500
  Shot "_start2" | Out-Null
  Crop "_start2" "_c81s5" 0 88 460 490 | Out-Null
  Annotate "_c81s5" "v_8_1-s5" @(
    @{ t='box'; x=16;  y=240; w=80;  h=30 }    # 导航里的「体验」
    @{ t='box'; x=246; y=372; w=184; h=56 }    # 卡片上的 🔒私人 + 名字
  ) 3 | Out-Null
  [Nw]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
  Start-Sleep -Milliseconds 600
  Click 1895 11 2500             # 关掉起始页实例
  "起始页实例已关"
}

# ── 网页那 6 张（8.3-s2/s3/s4、8.5-s1/s2/s3）───────────────────
# 网页部分**没有自动化**：用 Chrome 手动开到页面，再用 Focus-Win "chrome" + Shot
# 抓屏（比浏览器扩展截图清晰，像素跟 Studio 那些图是一套）。
# 三个入口（universeId / placeId 用命令栏 `print(game.GameId, game.PlaceId)` 取）：
#   作品列表      https://create.roblox.com/dashboard/creations
#   内容设置      https://create.roblox.com/dashboard/creations/experiences/<universeId>/configure
#   游戏页面      作品卡片 ⋯ → 在 Roblox 上查看（= roblox.com/games/<placeId>/...）
# 「受众」那一块在内容设置页的下半部分，Wheel 900 700 -5 正好滚到它。
# ⚠️ 别去碰那三个按钮（私人 / 受限 / 公开）—— 拍图不需要点它，点错了就是把用户的
#    体验改成公开。默认选中的就是「私人」，直接框住它就行。
function U8-Web {
  "网页图要手动：把 Chrome 开到对应页面，然后逐条跑下面的裁剪（坐标是本机 1920x1080 全屏 Chrome）"
  @'
# 作品列表页（先 Focus-Win "chrome"、Shot "_web_list"）
Crop "_web_list" "_c83s2" 76 140 430 470          # w=430：卡在第二张卡片（513）左边
Annotate "_c83s2" "v_8_3-s2" @( @{ t='box'; x=265; y=394; w=60; h=28 } ) 3

# 内容设置页顶部（Shot "_web1"）
Crop "_web1" "_c83s3" 76 140 620 420
Annotate "_c83s3" "v_8_3-s3" @( @{ t='box'; x=9; y=162; w=200; h=35 }, @{ t='box'; x=300; y=8; w=38; h=24 } ) 3

# 内容设置页往下滚 5 格之后的「受众」（Wheel 900 700 -5; Shot "_web2"）
Crop "_web2" "_c83s4" 336 440 780 145
Annotate "_c83s4" "v_8_3-s4" @( @{ t='box'; x=6; y=63; w=88; h=38 } ) 3

# 作品卡片的 ⋯ 菜单（Move-To 418 445; Click 477 388; Shot "_web_cardmenu"）
# ⚠️ 菜单是开关：已经开着时再点一次是关掉。而且 Focus-Win 会让它收起 ——
#    悬停→点开→截图必须写在同一次工具调用里。
Crop "_web_cardmenu" "_c85s1" 330 350 310 400     # w=310：菜单正好把右边两张卡片盖住
Annotate "_c85s1" "v_8_5-s1" @( @{ t='box'; x=140; y=147; w=155; h=24 } ) 3

# 游戏页面（Shot "_web_game"）
Crop "_web_game" "_c85s2" 150 40 700 48           # 只要地址栏那一条，不带半个标签页
Annotate "_c85s2" "v_8_5-s2" @( @{ t='box'; x=44; y=6; w=336; h=34 } ) 3
Crop "_web_game" "_c85s3" 600 180 1000 375
Annotate "_c85s3" "v_8_5-s3" @( @{ t='box'; x=670; y=245; w=300; h=58 } ) 3
'@
}

# ── 全部 ─────────────────────────────────────────────────────
# 顺序有一条硬约束：**两个弹窗的「处女状态」要在保存上云之前拍完**
# （U8-Menus → U8-SaveDlg → U8-PublishDlg），因为 place 一绑上云端，
# Ctrl+S 和 Alt+P 就都不弹窗了。之后才是 U8-DoSave / U8-DoPublish。
function U8-All {
  U8-Menus                       # 8.1-s1 / 8.2-s1
  U8-SaveDlg                     # 8.1-s2 / 8.1-s3（窗口留着）
  "接下来：U8-DoSave -Yes（会建体验）→ U8-DoPublish -Yes（会发布）→ U8-GameSettings → U8-Collab → U8-StartPage → U8-Web"
}
