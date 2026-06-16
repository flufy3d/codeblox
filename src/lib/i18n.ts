// 中文 UI 文案与常量（集中放置，便于统一口径）。
export const AVATARS = [
  '🦊', '🐱', '🐶', '🐼', '🐯', '🦄', '🐸', '🐧',
  '🐵', '🐲', '🦁', '🐰', '🐙', '🐢', '🦖', '🤖', '👾', '🐝',
];

export const UI = {
  appName: 'CodeBlox',
  tagline: '做出你自己的 Roblox 游戏',
  // 关卡地图
  continueLearning: '继续学习',
  startLearning: '开始第一课',
  locked: '先完成上一关哦',
  completed: '已完成',
  current: '现在学这关',
  // 课程页
  objectivesTitle: '🎯 今天你将学会',
  tasksTitle: '✅ 在 Studio 里完成这些',
  quizTitle: '🧠 小测验',
  challengeTitle: '🌶️ 想挑战一下？',
  completeBtn: '完成这一课！',
  completeNeedTasks: '把上面的任务都打勾，就能完成啦',
  completeNeedQuiz: '小测验答对一些再来完成吧',
  alreadyDone: '这一课你已经完成啦 ✅（可以重做巩固）',
  prev: '上一课',
  next: '下一课',
  backToMap: '← 回到关卡地图',
  // 档案
  whoLearning: '谁在学习？',
  newProfile: '＋ 新建小档案',
  pinPrompt: '请输入 4 位密码',
  pinWrong: '密码不对，再试试',
  // 通用
  level: '级',
  xp: 'XP',
  day: '天',
  streak: '连续打卡',
} as const;
