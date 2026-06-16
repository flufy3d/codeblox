// 仅供服务端（.astro 构建期）使用：从内容集构建课程目录。
// ⚠️ 不要在客户端孤岛里 import 它（它依赖 astro:content）。
import { getCollection } from 'astro:content';
import type { Catalog, CatalogUnit, CatalogLesson } from './types';

export async function buildCatalog(includeDrafts: boolean): Promise<Catalog> {
  const unitEntries = (await getCollection('units')).sort(
    (a, b) => a.data.order - b.data.order,
  );
  const lessonEntries = (await getCollection('lessons')).filter(
    (l) => includeDrafts || !l.data.draft,
  );
  const unitOrder = new Map(unitEntries.map((u) => [u.id, u.data.order]));

  const units: CatalogUnit[] = unitEntries.map((u) => ({
    id: u.id,
    order: u.data.order,
    title: u.data.title,
    subtitle: u.data.subtitle,
    emoji: u.data.emoji,
    color: u.data.color,
    badge: u.data.badge,
  }));

  const lessons: CatalogLesson[] = lessonEntries
    .map((l) => ({
      id: l.data.id,
      slug: l.id,
      unit: l.data.unit.id,
      order: l.data.order,
      title: l.data.title,
      emoji: l.data.emoji,
      xp: l.data.xp,
      estMinutes: l.data.estMinutes,
    }))
    .sort(
      (a, b) =>
        (unitOrder.get(a.unit) ?? 0) - (unitOrder.get(b.unit) ?? 0) || a.order - b.order,
    );

  return { units, lessons };
}
