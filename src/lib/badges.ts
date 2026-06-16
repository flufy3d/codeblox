// 徽章定义 + 根据进度计算应得徽章。
// 单元徽章来自 catalog.units[].badge（动态）；里程碑徽章固定在这里。
import type { Catalog, Progress } from './types';
import { levelForXp } from './progress';

export interface BadgeDef {
  id: string;
  name: string;
  emoji: string;
  desc: string; // 如何获得（展示在徽章墙）
}

export const MILESTONE_BADGES: BadgeDef[] = [
  { id: 'first-lesson', name: '迈出第一步', emoji: '🌱', desc: '完成你的第一节课' },
  { id: 'streak-3', name: '三天连击', emoji: '🔥', desc: '连续学习 3 天' },
  { id: 'streak-7', name: '一周不断', emoji: '🌟', desc: '连续学习 7 天' },
  { id: 'level-5', name: '五级小匠', emoji: '⚒️', desc: '等级达到 5 级' },
  { id: 'all-clear', name: '全部通关', emoji: '👑', desc: '完成全部课程' },
];

export function unitBadgeDefs(catalog: Catalog): BadgeDef[] {
  return catalog.units
    .filter((u) => u.badge)
    .map((u) => ({
      id: u.badge!.id,
      name: u.badge!.name,
      emoji: u.badge!.emoji,
      desc: `完成「${u.title}」全部课程`,
    }));
}

export function allBadgeDefs(catalog: Catalog): BadgeDef[] {
  return [...unitBadgeDefs(catalog), ...MILESTONE_BADGES];
}

export function badgeDefMap(catalog: Catalog): Record<string, BadgeDef> {
  const map: Record<string, BadgeDef> = {};
  for (const b of allBadgeDefs(catalog)) map[b.id] = b;
  return map;
}

/** 根据当前进度，计算“应当拥有”的全部徽章 id。 */
export function computeEarnedBadges(progress: Progress, catalog: Catalog): string[] {
  const earned = new Set<string>();
  const completedCount = Object.keys(progress.completedLessons).length;

  if (completedCount >= 1) earned.add('first-lesson');
  if (progress.streak.count >= 3) earned.add('streak-3');
  if (progress.streak.count >= 7) earned.add('streak-7');
  if (levelForXp(progress.xp) >= 5) earned.add('level-5');

  for (const u of catalog.units) {
    if (!u.badge) continue;
    const lessons = catalog.lessons.filter((l) => l.unit === u.id);
    if (lessons.length > 0 && lessons.every((l) => l.id in progress.completedLessons)) {
      earned.add(u.badge.id);
    }
  }

  if (
    catalog.lessons.length > 0 &&
    catalog.lessons.every((l) => l.id in progress.completedLessons)
  ) {
    earned.add('all-clear');
  }

  return [...earned];
}

/** 相比已记录的 badges，新获得的徽章 id（用于弹“获得新徽章”提示）。 */
export function newlyEarned(progress: Progress, catalog: Catalog): string[] {
  const should = computeEarnedBadges(progress, catalog);
  const have = new Set(progress.badges);
  return should.filter((id) => !have.has(id));
}
