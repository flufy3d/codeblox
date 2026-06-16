import { describe, it, expect } from 'vitest';
import {
  cumulativeXpForLevel,
  levelForXp,
  levelInfo,
  rollStreak,
  isUnlocked,
  firstIncompleteId,
  lessonState,
  scoreQuiz,
} from './progress';

describe('等级 / XP', () => {
  it('累计曲线', () => {
    expect(cumulativeXpForLevel(1)).toBe(0);
    expect(cumulativeXpForLevel(2)).toBe(100);
    expect(cumulativeXpForLevel(3)).toBe(300);
    expect(cumulativeXpForLevel(4)).toBe(600);
  });
  it('xp -> 等级', () => {
    expect(levelForXp(0)).toBe(1);
    expect(levelForXp(99)).toBe(1);
    expect(levelForXp(100)).toBe(2);
    expect(levelForXp(299)).toBe(2);
    expect(levelForXp(300)).toBe(3);
  });
  it('levelInfo 进度', () => {
    const i = levelInfo(150);
    expect(i.level).toBe(2);
    expect(i.into).toBe(50);
    expect(i.needed).toBe(200); // L2->L3 = 300-100
    expect(i.pct).toBeCloseTo(0.25);
  });
});

describe('连续打卡', () => {
  const d = (s: string) => new Date(s + 'T12:00:00');
  it('同一天不变', () => {
    const s = { count: 3, lastActiveDate: '2026-06-16' };
    expect(rollStreak(s, d('2026-06-16'))).toEqual(s);
  });
  it('连着昨天 +1', () => {
    const s = { count: 3, lastActiveDate: '2026-06-15' };
    expect(rollStreak(s, d('2026-06-16'))).toEqual({ count: 4, lastActiveDate: '2026-06-16' });
  });
  it('断了归 1', () => {
    const s = { count: 9, lastActiveDate: '2026-06-10' };
    expect(rollStreak(s, d('2026-06-16'))).toEqual({ count: 1, lastActiveDate: '2026-06-16' });
  });
});

describe('解锁逻辑', () => {
  const ids = ['1.1', '1.2', '1.3', '2.1'];
  it('第一课总是解锁', () => {
    expect(isUnlocked('1.1', ids, {})).toBe(true);
  });
  it('前一课没完成则锁住', () => {
    expect(isUnlocked('1.2', ids, {})).toBe(false);
    expect(isUnlocked('1.2', ids, { '1.1': 1 })).toBe(true);
  });
  it('第一个未完成', () => {
    expect(firstIncompleteId(ids, { '1.1': 1, '1.2': 1 })).toBe('1.3');
    expect(firstIncompleteId(ids, {})).toBe('1.1');
    expect(firstIncompleteId(ids, { '1.1': 1, '1.2': 1, '1.3': 1, '2.1': 1 })).toBe(null);
  });
  it('lessonState 状态', () => {
    const c = { '1.1': 1 };
    expect(lessonState('1.1', ids, c)).toBe('completed');
    expect(lessonState('1.2', ids, c)).toBe('current');
    expect(lessonState('1.3', ids, c)).toBe('locked');
  });
});

describe('测验评分', () => {
  it('单选全对', () => {
    expect(scoreQuiz([1, 0, 2], [1, 0, 2])).toBe(1);
  });
  it('部分正确', () => {
    expect(scoreQuiz([1, 1, 2], [1, 0, 2])).toBeCloseTo(2 / 3);
  });
  it('多选不计顺序', () => {
    expect(scoreQuiz([[2, 0]], [[0, 2]])).toBe(1);
    expect(scoreQuiz([[2]], [[0, 2]])).toBe(0);
  });
  it('没题目算满分', () => {
    expect(scoreQuiz([], [])).toBe(1);
  });
});
