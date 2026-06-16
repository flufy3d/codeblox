// ───────────────────────── 进度与档案 ─────────────────────────
export interface CompletionRecord {
  completedAt: string; // ISO 时间
  bestQuizScore: number; // 0..1，完成时的最好测验成绩快照
}

export interface Streak {
  count: number;
  lastActiveDate: string; // 本地 YYYY-MM-DD
}

export interface Progress {
  xp: number;
  completedLessons: Record<string, CompletionRecord>; // 按 lesson.id 索引，O(1) 判断是否完成
  taskProgress: Record<string, Record<string, boolean>>; // lessonId -> taskId -> 是否勾选
  quizScores: Record<string, number>; // lessonId -> 最近一次成绩 0..1
  badges: string[]; // 已获得徽章 id
  currentLessonId: string | null; // “继续学习”指针
  streak: Streak;
}

export interface PinData {
  salt: string;
  hash: string;
}

export interface Profile {
  id: string;
  name: string;
  avatar: string; // emoji 头像
  pin: PinData | null;
  createdAt: string;
  progress: Progress;
}

export interface CodeBloxStore {
  schemaVersion: number;
  activeProfileId: string | null;
  profiles: Record<string, Profile>;
}

// ───────────────────────── 课程目录（构建期注入，客户端只读）─────────────────────────
export interface CatalogUnitBadge {
  id: string;
  name: string;
  emoji: string;
}

export interface CatalogUnit {
  id: string;
  order: number;
  title: string;
  subtitle?: string;
  emoji: string;
  color: string;
  badge?: CatalogUnitBadge;
}

export interface CatalogLesson {
  id: string; // 稳定进度 key（如 "1.2"）
  slug: string; // 路由用（文件名派生）
  unit: string; // 所属单元 id
  order: number;
  title: string;
  emoji: string;
  xp: number;
  estMinutes: number;
}

export interface Catalog {
  units: CatalogUnit[]; // 已按 order 排序
  lessons: CatalogLesson[]; // 已按 (unit.order, order) 全局线性排序
}

// ───────────────────────── 导出/导入备份信封 ─────────────────────────
export interface ProfileExport {
  format: 'codeblox-progress';
  formatVersion: number;
  exportedAt: string;
  profile?: Profile; // 单档案备份
  profiles?: Record<string, Profile>; // “导出全部”整机备份
}
