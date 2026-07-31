# ══ 窗口 / 鼠标 / 键盘 ══════════════════════════════════════════
# ⚠️ 别把这个文件和 cap.ps1（截屏）合并 —— 见 cap.ps1 顶部的 AMSI 说明。
# ⚠️ 也别在这里加 GetAsyncKeyState：那是键盘记录器特征，AMSI 会直接拦掉整个文件。

Add-Type -AssemblyName System.Windows.Forms

if (-not ("Nw" -as [type])) {
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Nw {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, int dx, int dy, uint d, int e);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
"@
}

function Focus-Win([string]$NameLike = "RobloxStudio*") {
  $p = Get-Process | Where-Object { $_.ProcessName -like $NameLike -and $_.MainWindowHandle -ne 0 } | Select-Object -First 1
  if (-not $p) { throw "找不到窗口: $NameLike（Studio 开了吗？）" }
  $h = $p.MainWindowHandle
  if ([Nw]::IsIconic($h)) { [Nw]::ShowWindow($h, 9) | Out-Null }
  [Nw]::SetForegroundWindow($h) | Out-Null
  Start-Sleep -Milliseconds 500
  $r = New-Object Nw+RECT
  [Nw]::GetWindowRect($h, [ref]$r) | Out-Null
  [pscustomobject]@{ Left=$r.Left; Top=$r.Top; Width=$r.Right-$r.Left; Height=$r.Bottom-$r.Top; Title=$p.MainWindowTitle }
}

function Click([int]$X, [int]$Y, [int]$Delay=250) {
  [Nw]::SetCursorPos($X, $Y) | Out-Null
  Start-Sleep -Milliseconds 100
  [Nw]::mouse_event(2,0,0,0,0); [Nw]::mouse_event(4,0,0,0,0)
  Start-Sleep -Milliseconds $Delay
}

function RClick([int]$X, [int]$Y, [int]$Delay=250) {
  [Nw]::SetCursorPos($X, $Y) | Out-Null
  Start-Sleep -Milliseconds 100
  [Nw]::mouse_event(8,0,0,0,0); [Nw]::mouse_event(16,0,0,0,0)
  Start-Sleep -Milliseconds $Delay
}

function DblClick([int]$X, [int]$Y, [int]$Delay=250) {
  [Nw]::SetCursorPos($X, $Y) | Out-Null
  Start-Sleep -Milliseconds 100
  1..2 | ForEach-Object { [Nw]::mouse_event(2,0,0,0,0); [Nw]::mouse_event(4,0,0,0,0); Start-Sleep -Milliseconds 60 }
  Start-Sleep -Milliseconds $Delay
}

function Move-To([int]$X, [int]$Y) { [Nw]::SetCursorPos($X, $Y) | Out-Null; Start-Sleep -Milliseconds 120 }

function Wheel([int]$X, [int]$Y, [int]$Notches) {
  [Nw]::SetCursorPos($X, $Y) | Out-Null
  Start-Sleep -Milliseconds 100
  for ($i=0; $i -lt [math]::Abs($Notches); $i++) {
    [Nw]::mouse_event(0x0800, 0, 0, [uint32]([int]([math]::Sign($Notches) * 120)), 0)
    Start-Sleep -Milliseconds 40
  }
  Start-Sleep -Milliseconds 200
}

# 右键拖拽 = Studio 转视角。灵敏度约 3.1°/px（见 config.ps1 DragDegPerPx），
# 俯角在 ±90° 会被夹住，所以别用大位移去估灵敏度。
function RDrag([int]$X1, [int]$Y1, [int]$X2, [int]$Y2, [int]$Steps=24) {
  [Nw]::SetCursorPos($X1, $Y1) | Out-Null
  Start-Sleep -Milliseconds 150
  [Nw]::mouse_event(8,0,0,0,0)
  Start-Sleep -Milliseconds 150
  for ($i=1; $i -le $Steps; $i++) {
    [Nw]::SetCursorPos([int]($X1 + ($X2-$X1)*$i/$Steps), [int]($Y1 + ($Y2-$Y1)*$i/$Steps)) | Out-Null
    Start-Sleep -Milliseconds 16
  }
  Start-Sleep -Milliseconds 150
  [Nw]::mouse_event(16,0,0,0,0)
  Start-Sleep -Milliseconds 350
}

function Send([string]$Keys, [int]$Delay=250) {
  [System.Windows.Forms.SendKeys]::SendWait($Keys)
  Start-Sleep -Milliseconds $Delay
}

# ⚠️ 别用 SendKeys 往 Studio 里逐字打字：中文输入法会把空格当「上屏」吃掉，
# 还会乱改大小写。要输入文本一律走剪贴板 + Ctrl+V（见 studio.ps1 的 RunLua）。
function TypeText([string]$Text, [int]$Delay=250) {
  $esc = $Text -replace '([+^%~(){}])', '{$1}'
  $esc = $esc -replace '\[', '{[}' -replace '\]', '{]}'
  [System.Windows.Forms.SendKeys]::SendWait($esc)
  Start-Sleep -Milliseconds $Delay
}
