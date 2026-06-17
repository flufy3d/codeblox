// 段落朗读（Read Aloud）—— 用浏览器内置的 Web Speech API（speechSynthesis）。
// 免费、无需联网下载、无后端：给 .lesson-prose 里每个可读文字块末尾注入一个 🔊 按钮，
// 并在正文上方放一个"朗读整课 / 语速 / 选音"控制条。小测验里的 🔊 由 QuizBlock 调用本模块的
// speak()/toggleSpeak()，与正文共用同一个发声器（同时只读一个）。
//
// 复用项目约定（见 LessonLayout 里的截图放大脚本）：vanilla 增强 DOM、幂等、
// 支持 astro:page-load 视图过渡重复初始化。语速 / 选音存在当前档案里（store.ttsSettings）。
import { UI } from './i18n';
import { store } from './store.svelte';

// 可读区域：课程正文 + 标了 .tts-scope 的区块（"今天你将学会"目标框、挑战框等）。
// 块类型：标题 / 段落 / 列表项 / 引用块。代码块（pre/.codeblock）在 enhanceProse 里排除。
const READ_SCOPES = ['.lesson-prose', '.tts-scope'];
const READ_TAGS = ['h2', 'h3', 'p', 'li', 'blockquote'];
const BLOCK_SELECTOR = READ_SCOPES.flatMap((s) => READ_TAGS.map((t) => `${s} ${t}`)).join(', ');

// 朗读前从文本里去掉 emoji / 箭头 / 波浪号等符号（有些语音会把「～」念成"波浪"），读起来更干净
const SYMBOL_RE =
  /[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{2190}-\u{21FF}\u{FE00}-\u{FE0F}\u{1F1E6}-\u{1F1FF}\u{200D}\u{20E3}\u{301C}\u{FF5E}]/gu;

// ── 模块状态 ────────────────────────────────────────────────
let current: HTMLElement | null = null; // 当前高亮的块
let queue: HTMLElement[] = []; // "朗读整课"队列
let mode: 'idle' | 'one' | 'all' = 'idle';
let token = 0; // 抢占令牌：cancel() 触发的旧回调靠它失效

function isBrowser(): boolean {
  return typeof window !== 'undefined' && 'speechSynthesis' in window;
}

// ── 选音 ────────────────────────────────────────────────────
/** 列出系统里可用的中文语音（课程页选音 + 档案页"朗读设置"共用）。 */
export function listZhVoices(): SpeechSynthesisVoice[] {
  if (!isBrowser()) return [];
  return window.speechSynthesis
    .getVoices()
    .filter((v) => /^zh/i.test(v.lang) || /中文|chinese|普通话|mandarin/i.test(v.name));
}

// 已知优质语音名（靠前的更优先）
const KNOWN_GOOD = [
  'tingting',
  '婷婷',
  'xiaoxiao',
  '晓晓',
  'xiaoyi',
  'yunxi',
  '云希',
  'mei-jia',
  'meijia',
  'google 普通话',
  'google 中文',
];

function scoreVoice(v: SpeechSynthesisVoice): number {
  const n = v.name.toLowerCase();
  let s = 0;
  if (/natural|online/.test(n)) s += 100; // Edge 神经网络语音，最自然
  const idx = KNOWN_GOOD.findIndex((k) => n.includes(k));
  if (idx >= 0) s += 50 - idx;
  if (/^zh[-_]?cn/i.test(v.lang)) s += 10; // 普通话优先
  if (v.localService) s += 1; // 可离线，轻微加分
  return s;
}

function pickZhVoice(): SpeechSynthesisVoice | null {
  const list = listZhVoices();
  if (list.length === 0) return null;
  const wanted = store.ttsSettings.voiceURI;
  if (wanted) {
    const saved = list.find((v) => v.voiceURI === wanted);
    if (saved) return saved;
  }
  return list.slice().sort((a, b) => scoreVoice(b) - scoreVoice(a))[0] ?? null;
}

// 期望的语音是否已就绪。在线 / Google 中文语音常比本地语音晚几百毫秒才出现在列表里，
// 否则会"第一句用了旧声音、点第二句才对"。所以发声前先等它就绪。
function desiredVoiceReady(): boolean {
  const list = listZhVoices();
  if (list.length === 0) return false; // 列表还没加载
  const wanted = store.ttsSettings.voiceURI;
  if (!wanted) return true; // 自动模式：有列表即可
  return list.some((v) => v.voiceURI === wanted); // 指定的声音是否已出现
}

function whenVoiceReady(cb: () => void): void {
  if (desiredVoiceReady()) {
    cb();
    return;
  }
  let done = false;
  const finish = () => {
    if (done) return;
    done = true;
    window.speechSynthesis.removeEventListener('voiceschanged', onChange);
    cb();
  };
  const onChange = () => {
    if (desiredVoiceReady()) finish();
  };
  window.speechSynthesis.addEventListener('voiceschanged', onChange);
  window.speechSynthesis.getVoices(); // 触发加载
  setTimeout(finish, 1500); // 兜底：最多等 1.5s 就用当前最佳语音
}

// ── 文本与高亮 ──────────────────────────────────────────────
function cleanText(raw: string): string {
  return raw.replace(SYMBOL_RE, '').replace(/\s+/g, ' ').trim();
}

function textOf(el: HTMLElement): string {
  return el.dataset.ttsText || cleanText(el.textContent || '');
}

function clearHighlight(): void {
  document.querySelectorAll('.tts-reading').forEach((el) => el.classList.remove('tts-reading'));
  current = null;
}

function highlight(el: HTMLElement): void {
  clearHighlight();
  el.classList.add('tts-reading');
  current = el;
}

function makeUtterance(text: string): SpeechSynthesisUtterance | null {
  const t = cleanText(text);
  if (!t) return null;
  const u = new SpeechSynthesisUtterance(t);
  u.lang = 'zh-CN';
  const v = pickZhVoice(); // 懒选：每次发声时重选，规避 Chrome 首次 getVoices 为空
  if (v) u.voice = v;
  u.rate = store.ttsSettings.rate;
  u.pitch = 1.0;
  return u;
}

// ── 播放控制（公开 API：正文按钮、小测验都走这里）─────────────
function stop(): void {
  token++; // 让在途回调失效
  mode = 'idle';
  queue = [];
  if (isBrowser()) window.speechSynthesis.cancel();
  clearHighlight();
  updateBar();
}

/** 朗读一段文字；传入 el 时顺便高亮它。会打断正在朗读的内容。 */
export function speak(text: string, el?: HTMLElement): void {
  if (!isBrowser()) return;
  const synth = window.speechSynthesis;
  const my = ++token;
  synth.cancel();
  mode = 'one';
  if (el) highlight(el);
  else clearHighlight();
  updateBar();
  whenVoiceReady(() => {
    if (my !== token) return; // 等待语音期间被打断
    const u = makeUtterance(text);
    if (!u) {
      clearHighlight();
      mode = 'idle';
      updateBar();
      return;
    }
    u.onend = u.onerror = () => {
      if (my !== token) return;
      clearHighlight();
      mode = 'idle';
      updateBar();
    };
    synth.speak(u);
  });
}

/** 再点同一块 = 停；否则朗读它。 */
export function toggleSpeak(el: HTMLElement, text: string): void {
  if (mode === 'one' && current === el) stop();
  else speak(text, el);
}

// 朗读整课：逐块朗读正文，高亮并滚动到当前块
function readAll(): void {
  if (!isBrowser()) return;
  const synth = window.speechSynthesis;
  const my = ++token;
  synth.cancel();
  queue = Array.from(document.querySelectorAll<HTMLElement>('[data-tts="1"]'));
  if (queue.length === 0) {
    token++;
    return;
  }
  mode = 'all';
  updateBar();
  const step = (i: number): void => {
    if (my !== token) return; // 被 stop / 其它操作抢占
    if (i >= queue.length) {
      stop();
      return;
    }
    const el = queue[i];
    const u = makeUtterance(textOf(el));
    if (!u) {
      step(i + 1);
      return;
    }
    highlight(el);
    el.scrollIntoView({ block: 'center', behavior: 'smooth' });
    u.onend = () => step(i + 1);
    u.onerror = () => step(i + 1);
    synth.speak(u);
  };
  whenVoiceReady(() => {
    if (my === token) step(0); // 等首个语音就绪再开读
  });
}

// ── UI：每块的 🔊 按钮 ──────────────────────────────────────
function enhanceProse(): void {
  document.querySelectorAll<HTMLElement>(BLOCK_SELECTOR).forEach((el) => {
    if (el.dataset.tts === '1') return;
    if (el.closest('pre, code, .codeblock')) return; // 跳过代码
    const text = cleanText(el.textContent || '');
    if (!text) return; // 空块（如只含配图）跳过
    el.dataset.tts = '1';
    el.dataset.ttsText = text; // 在注入按钮之前抓取，避免把 🔊 读进去
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'tts-btn';
    btn.textContent = '🔊';
    btn.setAttribute('aria-label', UI.ttsListen);
    el.appendChild(btn);
  });
}

// ── UI：控制条 ──────────────────────────────────────────────
function updateBar(): void {
  document.querySelectorAll<HTMLButtonElement>('.tts-play').forEach((play) => {
    play.textContent = mode === 'all' ? UI.ttsStop : UI.ttsPlayAll;
  });
}

function mountBar(): void {
  const prose = document.querySelector('.lesson-prose');
  const host = prose?.parentElement;
  if (!prose || !host) return;
  if (host.querySelector('.tts-bar')) return; // 已挂

  const bar = document.createElement('div');
  bar.className = 'tts-bar';

  // 只保留"朗读整课 / 停止"。语速与选音在「我的档案」页设置（每个孩子各一份）。
  const play = document.createElement('button');
  play.type = 'button';
  play.className = 'tts-bar-btn tts-play';
  play.textContent = UI.ttsPlayAll;
  play.addEventListener('click', () => (mode === 'all' ? stop() : readAll()));
  bar.appendChild(play);

  host.insertBefore(bar, prose);
  updateBar();
}

// ── 点击委托（全局挂一次，跨视图过渡有效）────────────────────
function onDocClick(e: MouseEvent): void {
  const btn = (e.target as HTMLElement).closest('.tts-btn');
  if (!btn) return;
  const block = btn.closest<HTMLElement>('[data-tts="1"]'); // 只处理正文块；小测验的 🔊 由组件自己处理
  if (!block) return;
  toggleSpeak(block, textOf(block));
}

// ── 入口（幂等，可在每次 astro:page-load 调用）──────────────
export function initLessonTTS(): void {
  if (!isBrowser()) return; // SSR / 不支持的浏览器：直接降级，不注入按钮
  store.hydrate(); // 载入当前档案（含朗读设置），幂等
  if (!document.querySelector('.lesson-prose')) return; // 只在课程页生效

  enhanceProse();
  mountBar();
  window.speechSynthesis.getVoices(); // 预热语音列表，缩短首句等待

  if ((window as unknown as { __ttsReady?: boolean }).__ttsReady) return;
  (window as unknown as { __ttsReady?: boolean }).__ttsReady = true;

  document.addEventListener('click', onDocClick);
  document.addEventListener('astro:before-swap', stop); // 离开页面时停止朗读
  window.addEventListener('beforeunload', () => window.speechSynthesis.cancel());
}
