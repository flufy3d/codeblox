// localStorage 读写、迁移、工厂函数。单一顶层 key，便于整体导出/导入。
import type { CodeBloxStore, Profile, Progress, ProfileSettings, TtsSettings } from './types';

export const STORAGE_KEY = 'codeblox.v1';
export const SCHEMA_VERSION = 2;

export function defaultTtsSettings(): TtsSettings {
  return { rate: 0.9, voiceURI: null };
}

export function defaultSettings(): ProfileSettings {
  return { tts: defaultTtsSettings() };
}

export function emptyProgress(): Progress {
  return {
    xp: 0,
    completedLessons: {},
    taskProgress: {},
    quizScores: {},
    badges: [],
    currentLessonId: null,
    streak: { count: 0, lastActiveDate: '' },
  };
}

export function emptyStore(): CodeBloxStore {
  return { schemaVersion: SCHEMA_VERSION, activeProfileId: null, profiles: {} };
}

function shortId(): string {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID().slice(0, 8);
  }
  return Math.random().toString(36).slice(2, 10);
}

export function makeProfile(name: string, avatar: string): Profile {
  return {
    id: 'p_' + shortId(),
    name,
    avatar,
    pin: null,
    createdAt: new Date().toISOString(),
    progress: emptyProgress(),
    settings: defaultSettings(),
  };
}

// 给一个档案补齐 settings（朗读等），用于迁移老数据 / 导入旧备份。就地修改，幂等。
export function ensureSettings(p: { settings?: ProfileSettings }): void {
  if (!p.settings) p.settings = defaultSettings();
  else if (!p.settings.tts) p.settings.tts = defaultTtsSettings();
}

export function freshProfileId(): string {
  return 'p_' + shortId();
}

function isBrowser(): boolean {
  return typeof window !== 'undefined' && typeof window.localStorage !== 'undefined';
}

// 向前迁移旧版本数据（未来 schema 升级在这里加 if (v < N) {...}）
function migrate(data: unknown): CodeBloxStore {
  if (!data || typeof data !== 'object') return emptyStore();
  const store = data as CodeBloxStore;
  if (typeof store.profiles !== 'object' || store.profiles === null) return emptyStore();
  // v2：给每个档案补齐 settings（朗读语速 / 选音）
  for (const p of Object.values(store.profiles)) ensureSettings(p);
  store.schemaVersion = SCHEMA_VERSION;
  return store;
}

export function load(): CodeBloxStore {
  if (!isBrowser()) return emptyStore();
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return emptyStore();
    return migrate(JSON.parse(raw));
  } catch {
    return emptyStore();
  }
}

export function save(store: CodeBloxStore): void {
  if (!isBrowser()) return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
  } catch {
    // 配额满 / 隐私模式：静默失败
  }
}
