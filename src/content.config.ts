import { defineCollection, reference } from 'astro:content';
import { z } from 'astro:schema';
import { glob } from 'astro/loaders';

// ───────────────────────── 单元（关卡地图上的“大关”）─────────────────────────
// 每个单元一个 yaml 文件；entry 的 id 来自文件名（如 unit-01.yaml -> "unit-01"），
// 课程用 unit: reference('units') 按这个 id 关联，构建期校验外键是否存在。
const units = defineCollection({
  loader: glob({ pattern: '**/*.{yaml,yml}', base: './src/content/units' }),
  schema: z.object({
    order: z.number().int(), // 单元在地图上的顺序
    title: z.string(),
    subtitle: z.string().optional(),
    emoji: z.string().default('📦'),
    color: z.string().default('#6C8AE4'), // 地图分段主题色
    // 完成本单元最后一课时颁发的徽章
    badge: z
      .object({ id: z.string(), name: z.string(), emoji: z.string() })
      .optional(),
  }),
});

// 一道选择题
const quizQuestion = z.object({
  q: z.string(),
  type: z.enum(['single', 'multi']).default('single'),
  options: z.array(z.string()).min(2),
  answer: z.union([z.number().int(), z.array(z.number().int())]), // 选项下标（单选数字 / 多选数组）
  explain: z.string().optional(), // 作答后显示的解析
});

// ───────────────────────── 课程（一个文件 = 一节课）─────────────────────────
const lessons = defineCollection({
  loader: glob({ pattern: '**/*.mdx', base: './src/content/lessons' }),
  schema: z.object({
    // 稳定唯一 id（如 "1.2"），是 localStorage 进度的 key —— 永不复用 / 重排。
    // 文件名 / order 可随意调整，进度不会丢。
    id: z.string(),
    unit: reference('units'), // 外键到某个单元
    order: z.number(), // 单元内顺序
    title: z.string(),
    emoji: z.string().default('⭐'), // 地图节点图标
    estMinutes: z.number().int().positive().default(15),
    xp: z.number().int().positive().default(100),
    objectives: z.array(z.string()).min(1), // “你将学会…”
    tasks: z
      .array(z.object({ id: z.string(), label: z.string() }))
      .default([]), // 在 Studio 里要做的清单
    quiz: z.array(quizQuestion).default([]),
    challenge: z.string().optional(), // “想挑战一下？”（可选）
    draft: z.boolean().default(false), // true = 写作中，生产构建隐藏
  }),
});

export const collections = { units, lessons };
