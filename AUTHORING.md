# CodeBlox 课程作者指南

这份文档讲**如何写一节课**。加一节课 = 在 `src/content/lessons/` 里加一个 `.mdx` 文件，它会自动出现在关卡地图上、生成自己的页面、按 frontmatter 渲染任务清单和测验。无需改任何代码。

---

## 1. 文件名与位置

- 路径：`src/content/lessons/`
- 命名：`UU-LL-英文短名.mdx`，例如 `03-02-print-hello.mdx`
  - `UU` = 单元号（两位），`LL` = 单元内课序（两位）。文件名只决定 URL 和排序，**不**决定进度 key。

---

## 2. Frontmatter（必须严格符合，否则构建失败）

```yaml
---
id: "3.2"                 # 稳定唯一 id（"单元.课序"）。这是进度存档的 key，一旦发布【永不修改】
unit: unit-03             # 所属单元，必须等于某个 src/content/units/ 里的文件名（去掉扩展名）
order: 2                  # 单元内顺序（数字）
title: print 说“你好”      # 课程标题（中文）
emoji: "💬"               # 地图节点图标
estMinutes: 18            # 预计时长（分钟）
xp: 100                   # 完成奖励 XP（普通课 100，单元最后一课用 150）
objectives:               # “今天你将学会”，至少 1 条
  - 学会用 print 在 Output 窗口打印文字
tasks:                    # 在 Studio 里要做的清单（可为空 []，但建议有）
  - id: t1                # id 用 t1/t2/t3…
    label: 在 Workspace 里插入一个 Script
  - id: t2
    label: 把代码改成 print("你好，Roblox！")
quiz:                     # 2-3 道选择题（可为空 []，但建议有）
  - q: print() 的作用是什么？
    type: single          # single=单选 / multi=多选
    options: ["删除零件", "在 Output 窗口显示文字", "让角色跳"]
    answer: 1             # 正确选项的下标（从 0 开始）；多选时用数组如 [0, 2]
    explain: print 会把内容显示在 Output 窗口，常用来检查代码。  # 可选，作答后显示
challenge: 再加一行 print，把你的名字也打印出来。   # 可选，“想挑战一下？”
---
```

**校验要点**（构建期 Zod 强制）：`objectives` 至少 1 条；`options` 至少 2 个；单选 `answer` 是数字，多选是数字数组；`unit` 必须指向真实存在的单元文件。写错会让 `npm run build` 直接失败并指出哪一行。

---

## 3. 正文结构（每节课统一骨架）

正文用 Markdown 写，配合下面几个组件。**建议固定这个顺序**（任务清单、测验、完成按钮、上一课/下一课会由系统在正文下面自动渲染，正文里不用写）：

```mdx
## 🎯 今天要做什么
一句话说清目标 + 做完会得到什么很酷的东西（先勾起兴趣）。

## ✨ 新知识：<一个概念>
只讲 1 个新概念，用生活化比喻。绝不一次塞两个。

<StudioStep n={1} title="第一步做什么">
具体操作。菜单名给中文+英文，如 **Home（主页）选项卡 → Insert → Part**。
</StudioStep>

<StudioStep n={2} title="下一步">
…
</StudioStep>

## 🕹️ 看看你的成果
怎么试玩 / 怎么确认成功的样子。

<Callout type="warning">
“如果没成功？”——列 1-2 个最常见错误和怎么修。
</Callout>
```

`🎯 今天你将学会` 不用自己写（系统会用 frontmatter 的 `objectives` 自动渲染在标题下方）。

---

## 4. 可用组件（无需 import，直接用）

- `<StudioStep n={数字} title="标题">…</StudioStep>` —— 编号的 Studio 操作步骤。
- `<Callout type="tip">…</Callout>` —— 提示框。`type` 可为 `tip`（💡绿）/ `warning`（⚠️黄）/ `info`（ℹ️蓝）。

### 代码怎么写
用 Markdown 围栏代码块，语言写 `lua`（会自动语法高亮）：

````mdx
```lua
print("你好，Roblox！")
```
````

**给孩子的代码原则**：先“整段给”，再让他们只改一两个地方。需要时在正文里用 **加粗** 或文字说明“把这里的 `红色` 改成你喜欢的颜色”。

> ⚠️ Luau 的变量名、函数名**只能用英文字母/数字/下划线**，不能用中文！变量名用简单英文（如 `part`、`points`），中文写在注释或正文讲解里。

---

## 5. 校对过的 Roblox Studio / Luau 事实（2026）

操作步骤请以这些为准（已对照官方文档）：

- 插入物体：**Home 选项卡 → Insert → Part**；或在 Explorer 里**右键某对象 → Insert Object**。
- 打开面板：**View 选项卡 → Explorer / Properties / Output**。
- 写脚本：在 Explorer 里**右键 Workspace（或某个 Part）→ Insert Object → Script**。让所有玩家都生效的“服务器脚本”放在 **ServerScriptService**。
- 试玩：顶部 **▶️ Play**；停止：**⏹️ Stop**。镜头：按住鼠标右键转视角，**W/A/S/D** 移动，**E/Q** 升降。
- Output 窗口看 `print` 输出和红色报错；90% 的报错是拼写 / 大小写 / 引号问题。

### 经典代码片段（直接用，别改结构）

**第一个脚本（放在一个 Part 里，碰到就变色）—— Touched 事件：**
```lua
local part = script.Parent

local function onTouch(hit)
	part.BrickColor = BrickColor.Random()
end

part.Touched:Connect(onTouch)
```

**计分板 leaderstats（放在 ServerScriptService 的 Script 里）：**
```lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"   -- 名字必须正好是 leaderstats（全小写）
	leaderstats.Parent = player

	local points = Instance.new("IntValue")
	points.Name = "Points"
	points.Value = 0
	points.Parent = leaderstats
end)
```

**碰到得分垫 +1 分（带 debounce 去抖，放在 Pad 这个 Part 里）：**
```lua
local pad = script.Parent
local debounce = false

pad.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player and not debounce then
		debounce = true
		player.leaderstats.Points.Value += 1
		task.wait(1)
		debounce = false
	end
end)
```

---

## 6. 写课原则（面向 8 岁，也不让 11 岁觉得无聊）

1. 步骤拆到最小，每步一个动作；菜单名写全。
2. 每节课结尾必须有“能看 / 能玩”的成果。
3. 一节课只教一个新概念。
4. `challenge`（想挑战一下？）永远只是“改个数字 / 多做一个 / 把两个连起来”，**不引入未教过的新语法**。
5. 全中文；技术名词给“中文（English）”。

---

## 7. 本地命令

- `npm run dev` 开发预览（`http://localhost:4321/codeblox/`）
- `npm run build` 构建（会校验所有课程 frontmatter）
- `npm run check` 类型检查　`npm test` 单测

---

## 8. 完整课程地图（单元 → 课）

| 单元 | 主题 | 锚点项目 | 课数 |
|---|---|---|---|
| unit-01 | 走进 Studio | 我的迷你乐园 | 7 ✅ |
| unit-02 | 属性的魔法 | 发光传送门 + 漂浮岛 | 6 |
| unit-03 | 第一个脚本 | 会变色的霓虹方块 | 7 |
| unit-04 | 变量与事件 | 碰到就反应的魔法地板 | 7 |
| unit-05 | 逻辑与重复 | 彩虹跑道 + 熔岩 | 8 |
| unit-06 | 玩家与分数 | 得分垫 + 计分板 | 8 |
| unit-07 | 组装完整小游戏 | 完整障碍跑酷 Obby | 9 |
| unit-08 | 发布与分享 | 发布上线 + 可分享链接 | 5 |

第 1 单元已完整写好，可作为写作范例参考（`src/content/lessons/01-*.mdx`）。
