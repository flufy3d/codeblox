# 🎮 CodeBlox — 少儿 Roblox 编程在线课程

把孩子从"只玩游戏"变成"会做游戏"。一套游戏化的中文在线课程，带 8–11 岁的孩子用 **Roblox Studio（Luau）** 一步步做出自己的游戏。

🔗 在线访问：<https://flufy3d.github.io/codeblox/>

## 这是什么

- **关卡地图式课程**：8 个单元、57 节课，从认识 Studio 到发布自己的小游戏；每节课都有"能玩 / 能看"的成果。
- **本地档案 + 进度**：每个孩子一个档案（可设 4 位密码防互相覆盖），进度存在浏览器本地，可一键导出 / 导入备份。**无需服务器、无需注册账号。**
- **游戏化**：经验值（XP）、等级、连续打卡、徽章墙。
- 写代码全部在 Roblox Studio 里完成；网站负责讲解、配图、任务清单、小测验、进度记录。

## 技术栈

Astro（静态站）· Svelte 5 runes（交互孤岛）· Tailwind CSS v4 · MDX（课程内容）· localStorage（进度）→ GitHub Pages（GitHub Actions 自动部署）。

## 常用命令

| 命令 | 作用 |
| :-- | :-- |
| `npm install` | 安装依赖 |
| `npm run dev` | 本地开发：<http://localhost:4321/codeblox/> |
| `npm run build` | 生产构建（构建期校验所有课程 frontmatter） |
| `npm run preview` | 预览构建产物（验证 base 路径） |
| `npm run check` | 类型检查 |
| `npm test` | 单元测试（等级 / 连击 / 解锁 / 评分逻辑） |
| `npx playwright test` | E2E 关键路径测试（建档案 → 完成课 → 进度持久化） |

## 加一节课

加一节课 = 在 `src/content/lessons/` 里加一个 `.mdx` 文件，它会自动出现在关卡地图上、生成页面、按 frontmatter 渲染任务清单与测验。完整规范见 **[AUTHORING.md](./AUTHORING.md)**（frontmatter schema、正文模板、可用组件、校对过的 Luau 代码片段、完整课程清单）。

## 目录结构

```text
src/
├─ content.config.ts          # 内容集 + Zod schema（构建期校验每节课）
├─ content/
│  ├─ units/                  # 8 个单元元数据（yaml）
│  └─ lessons/                # 57 节课（一个 .mdx = 一节课）
├─ components/
│  ├─ CatalogData.astro       # 构建期生成课程目录 JSON，注入页面
│  ├─ astro/                  # 静态组件：StudioStep / CodeBlock / Callout
│  └─ islands/                # Svelte 交互：ProfileSwitcher / ProgressMap / QuizBlock …
├─ lib/                       # store.svelte.ts（档案 store）/ progress.ts / badges.ts / pin.ts …
├─ layouts/                   # BaseLayout / LessonLayout
└─ pages/                     # index（关卡地图）/ lessons/[...slug] / badges / profile / 404
```

## 部署

push 到 `main` 即由 `.github/workflows/deploy.yml` 自动构建并发布到 GitHub Pages。
仓库名为 `codeblox`，对应 `astro.config.mjs` 里的 `base: '/codeblox'`——**改仓库名要同步改 base**，否则线上资源会 404。

## 给家长

- 进度只存在本设备浏览器里。换设备 / 清缓存前，在「我的档案」页**导出备份**，到新设备再导入。
- 第 8 单元（发布与分享）请**家长在场**操作，默认设为私密 / 仅好友。Roblox 对不同年龄段账号的公开与社交权限不同，以家长账号控制台和当时的官方政策为准。
