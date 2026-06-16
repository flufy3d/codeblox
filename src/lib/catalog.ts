// 客户端只读：从页面里嵌入的 <script type="application/json"> 读取课程目录。
// 目录由 Astro 在构建期生成（见 components/CatalogData.astro），孩子端不重复请求。
import type { Catalog } from './types';

export const CATALOG_SCRIPT_ID = 'codeblox-catalog';

const EMPTY: Catalog = { units: [], lessons: [] };
let cached: Catalog | null = null;

export function readCatalog(): Catalog {
  if (cached) return cached;
  if (typeof document === 'undefined') return EMPTY;
  const el = document.getElementById(CATALOG_SCRIPT_ID);
  if (!el?.textContent) return EMPTY;
  try {
    cached = JSON.parse(el.textContent) as Catalog;
  } catch {
    cached = EMPTY;
  }
  return cached ?? EMPTY;
}

/** 全局线性顺序的 lesson id 列表（解锁逻辑用）。 */
export function orderedLessonIds(catalog: Catalog): string[] {
  return catalog.lessons.map((l) => l.id);
}
