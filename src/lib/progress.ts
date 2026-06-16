// 纯逻辑：等级/XP、连续打卡、解锁规则、测验评分。
// 不依赖 DOM / localStorage / Svelte，方便单测（now 等通过参数传入）。
import type { Streak } from './types';

// ───────────────────────── 等级与 XP ─────────────────────────
// 三角形曲线：到达 level L 所需累计 XP = 100 * (L-1)*L/2。
// L1=0, L2=100, L3=300, L4=600, L5=1000…（每课约 100 XP，早期 1~2 课升一级）
export const XP_BASE = 100;

export function cumulativeXpForLevel(level: number): number {
  const l = Math.max(1, Math.floor(level));
  return (XP_BASE * (l - 1) * l) / 2;
}

export function levelForXp(xp: number): number {
  let level = 1;
  while (cumulativeXpForLevel(level + 1) <= xp) level++;
  return level;
}

export interface LevelInfo {
  level: number;
  into: number; // 当前等级内已获得的 XP
  needed: number; // 当前等级升到下一级需要的 XP
  pct: number; // 0..1 进度
}

export function levelInfo(xp: number): LevelInfo {
  const level = levelForXp(xp);
  const base = cumulativeXpForLevel(level);
  const next = cumulativeXpForLevel(level + 1);
  const into = Math.max(0, xp - base);
  const needed = next - base;
  return { level, into, needed, pct: needed > 0 ? Math.min(1, into / needed) : 1 };
}

// ───────────────────────── 日期 / 连续打卡 ─────────────────────────
export function dateStr(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

/** 在某天“打卡”后的新连击状态：同一天不变；接着昨天 +1；断了则归 1。 */
export function rollStreak(streak: Streak, now: Date): Streak {
  const today = dateStr(now);
  if (streak.lastActiveDate === today) return streak;
  const y = new Date(now);
  y.setDate(y.getDate() - 1);
  const yesterday = dateStr(y);
  if (streak.lastActiveDate === yesterday) {
    return { count: streak.count + 1, lastActiveDate: today };
  }
  return { count: 1, lastActiveDate: today };
}

// ───────────────────────── 解锁逻辑（线性序列）─────────────────────────
export function isUnlocked(
  lessonId: string,
  orderedIds: string[],
  completed: Record<string, unknown>,
): boolean {
  const idx = orderedIds.indexOf(lessonId);
  if (idx < 0) return false;
  if (idx === 0) return true; // 第一课默认解锁
  return orderedIds[idx - 1] in completed; // 前一课完成则解锁
}

export function firstIncompleteId(
  orderedIds: string[],
  completed: Record<string, unknown>,
): string | null {
  for (const id of orderedIds) if (!(id in completed)) return id;
  return null;
}

export type LessonState = 'completed' | 'current' | 'unlocked' | 'locked';

export function lessonState(
  lessonId: string,
  orderedIds: string[],
  completed: Record<string, unknown>,
): LessonState {
  if (lessonId in completed) return 'completed';
  if (!isUnlocked(lessonId, orderedIds, completed)) return 'locked';
  return firstIncompleteId(orderedIds, completed) === lessonId ? 'current' : 'unlocked';
}

// ───────────────────────── 测验评分 ─────────────────────────
/** 完成一节课所需的测验通过线（≥ 2/3）。 */
export const QUIZ_PASS = 2 / 3;

function answersEqual(a: number | number[] | undefined, b: number | number[]): boolean {
  if (Array.isArray(b)) {
    if (!Array.isArray(a)) return false;
    const sa = [...a].sort((x, y) => x - y);
    const sb = [...b].sort((x, y) => x - y);
    return sa.length === sb.length && sa.every((v, i) => v === sb[i]);
  }
  return a === b;
}

/** 给一组作答打分，返回 0..1（没有题目时视为满分）。 */
export function scoreQuiz(
  answers: Array<number | number[] | undefined>,
  correct: Array<number | number[]>,
): number {
  if (correct.length === 0) return 1;
  let ok = 0;
  for (let i = 0; i < correct.length; i++) {
    if (answersEqual(answers[i], correct[i])) ok++;
  }
  return ok / correct.length;
}
