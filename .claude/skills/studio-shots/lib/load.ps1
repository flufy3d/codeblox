# 一次性加载全部库。用法（必须 dot-source）：
#   . "D:\Projects\CodeBlox\.claude\skills\studio-shots\lib\load.ps1"
# 之后 Focus-Win / RunLua / Aim-Shot / ContactSheet 等函数就都可用了。
. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\cap.ps1"
. "$PSScriptRoot\win.ps1"
. "$PSScriptRoot\studio.ps1"
. "$PSScriptRoot\aim.ps1"
"studio-shots 已加载 · 输出目录: $script:SD"
