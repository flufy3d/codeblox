// 全站交互的心脏：localStorage 支撑的 Svelte 5 runes 响应式档案 store（单例）。
// 所有孤岛 import 同一个 store，读写它即可联动。每次改动后立即持久化。
import { load, save, emptyStore, makeProfile, freshProfileId } from './storage';
import type { CodeBloxStore, Profile, PinData, ProfileExport } from './types';
import { readCatalog, orderedLessonIds } from './catalog';
import { rollStreak, levelInfo, firstIncompleteId } from './progress';
import { newlyEarned } from './badges';

export interface CompleteResult {
  newBadges: string[];
  leveledUp: boolean;
  level: number;
  awardedXp: number;
}

class ProfileStore {
  data = $state<CodeBloxStore>(emptyStore());
  hydrated = $state(false);

  /** 客户端首次挂载时调用，从 localStorage 载入（幂等）。 */
  hydrate() {
    if (this.hydrated) return;
    this.data = load();
    this.hydrated = true;
  }

  private persist() {
    save($state.snapshot(this.data) as CodeBloxStore);
  }

  // ───────── 档案 ─────────
  get profileList(): Profile[] {
    return Object.values(this.data.profiles).sort((a, b) =>
      a.createdAt.localeCompare(b.createdAt),
    );
  }

  get active(): Profile | null {
    const id = this.data.activeProfileId;
    return id ? (this.data.profiles[id] ?? null) : null;
  }

  addProfile(name: string, avatar: string): string {
    const p = makeProfile(name, avatar);
    this.data.profiles[p.id] = p;
    this.data.activeProfileId = p.id;
    this.persist();
    return p.id;
  }

  setActive(id: string) {
    if (this.data.profiles[id]) {
      this.data.activeProfileId = id;
      this.persist();
    }
  }

  removeProfile(id: string) {
    delete this.data.profiles[id];
    if (this.data.activeProfileId === id) {
      this.data.activeProfileId = this.profileList[0]?.id ?? null;
    }
    this.persist();
  }

  renameProfile(id: string, name: string, avatar: string) {
    const p = this.data.profiles[id];
    if (!p) return;
    p.name = name;
    p.avatar = avatar;
    this.persist();
  }

  setPin(id: string, pin: PinData | null) {
    const p = this.data.profiles[id];
    if (!p) return;
    p.pin = pin;
    this.persist();
  }

  // ───────── 课内进度 ─────────
  taskState(lessonId: string): Record<string, boolean> {
    return this.active?.progress.taskProgress[lessonId] ?? {};
  }

  setTask(lessonId: string, taskId: string, checked: boolean) {
    const p = this.active?.progress;
    if (!p) return;
    (p.taskProgress[lessonId] ??= {})[taskId] = checked;
    this.persist();
  }

  quizScore(lessonId: string): number {
    return this.active?.progress.quizScores[lessonId] ?? 0;
  }

  setQuizScore(lessonId: string, score: number) {
    const p = this.active?.progress;
    if (!p) return;
    p.quizScores[lessonId] = score;
    this.persist();
  }

  isComplete(lessonId: string): boolean {
    return !!this.active && lessonId in this.active.progress.completedLessons;
  }

  /** 完成一节课：首次才发 XP，记录完成、推进指针、打卡、结算徽章。 */
  completeLesson(lessonId: string, xp: number, quizScore: number): CompleteResult {
    const p = this.active?.progress;
    if (!p) return { newBadges: [], leveledUp: false, level: 1, awardedXp: 0 };

    const beforeLevel = levelInfo(p.xp).level;
    const firstTime = !(lessonId in p.completedLessons);
    const awardedXp = firstTime ? xp : 0;
    if (firstTime) p.xp += xp;

    const prevBest = p.completedLessons[lessonId]?.bestQuizScore ?? 0;
    p.completedLessons[lessonId] = {
      completedAt: new Date().toISOString(),
      bestQuizScore: Math.max(prevBest, quizScore),
    };

    const cat = readCatalog();
    p.currentLessonId = firstIncompleteId(orderedLessonIds(cat), p.completedLessons);
    p.streak = rollStreak(p.streak, new Date());

    const fresh = newlyEarned(p, cat);
    if (fresh.length) p.badges = [...p.badges, ...fresh];

    const afterLevel = levelInfo(p.xp).level;
    this.persist();
    return { newBadges: fresh, leveledUp: afterLevel > beforeLevel, level: afterLevel, awardedXp };
  }

  // ───────── 导出 / 导入备份 ─────────
  exportAll(): ProfileExport {
    return {
      format: 'codeblox-progress',
      formatVersion: 1,
      exportedAt: new Date().toISOString(),
      profiles: $state.snapshot(this.data.profiles) as Record<string, Profile>,
    };
  }

  exportProfile(id: string): ProfileExport | null {
    const p = this.data.profiles[id];
    if (!p) return null;
    return {
      format: 'codeblox-progress',
      formatVersion: 1,
      exportedAt: new Date().toISOString(),
      profile: $state.snapshot(p) as Profile,
    };
  }

  /** 导入一个档案；asCopy=true 时分配新 id 并加“（副本）”，否则按原 id 覆盖/新增。 */
  importProfile(prof: Profile, asCopy: boolean): string {
    const clone = JSON.parse(JSON.stringify(prof)) as Profile;
    if (asCopy) {
      clone.id = freshProfileId();
      clone.name = clone.name + '（副本）';
    }
    this.data.profiles[clone.id] = clone;
    this.data.activeProfileId = clone.id;
    this.persist();
    return clone.id;
  }
}

export const store = new ProfileStore();
