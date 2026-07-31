#!/usr/bin/env node
// 把拍好的 PNG 转成 webp 存进 public/shots/<id>.webp
//
// 用法（在仓库根目录跑）：
//   node .claude/skills/studio-shots/tools/save-shots.mjs <源目录>
//     → 自动把 v_2_1-s3.png 映射成 2.1-s3.webp
//   node .claude/skills/studio-shots/tools/save-shots.mjs <源目录> 2.1-s3 2.6-s1
//     → 只存指定的 id
//   加 --dry 只打印不写盘
//
// 参数与截图控制台（scripts/shot-console.html）保持一致：最长边 1600、webp q90。
// ⚠️ sharp 是 astro 的间接依赖，不是直接依赖 —— 万一升级依赖后没了，
//    改用截图控制台粘贴那条路（npm run shots），或把 sharp 加进 devDependencies。

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const MAX = 1600;
const QUALITY = 90;
const SHOTS_DIR = path.resolve('public/shots');
const LESSONS_DIR = path.resolve('src/content/lessons');
const ID_OK = /^\d+\.\d+-s\d+$/;

let sharp;
try {
  ({ default: sharp } = await import('sharp'));
} catch {
  console.error('找不到 sharp。它是 astro 的间接依赖，可能已被移除。');
  console.error('要么 npm i -D sharp，要么走截图控制台粘贴（npm run shots）。');
  process.exit(1);
}

const args = process.argv.slice(2);
const dry = args.includes('--dry');
const rest = args.filter((a) => a !== '--dry');
const srcDir = rest[0];
const onlyIds = new Set(rest.slice(1));

if (!srcDir || !fs.existsSync(srcDir)) {
  console.error('用法: node save-shots.mjs <源目录> [id ...] [--dry]');
  process.exit(1);
}
if (!fs.existsSync(SHOTS_DIR)) {
  console.error(`找不到 ${SHOTS_DIR} —— 请在仓库根目录运行`);
  process.exit(1);
}

// v_2_1-s3.png → 2.1-s3
function idFromFile(f) {
  const m = /^v_(\d+)_(\d+-s\d+)\.png$/i.exec(f);
  return m ? `${m[1]}.${m[2]}` : null;
}

// 收集课程里真正引用了的 <Shot id="...">，避免存出孤儿图
const referenced = new Set();
for (const f of fs.readdirSync(LESSONS_DIR)) {
  if (!f.endsWith('.mdx')) continue;
  const txt = fs.readFileSync(path.join(LESSONS_DIR, f), 'utf8');
  for (const m of txt.matchAll(/<Shot\s+id="([^"]+)"/g)) referenced.add(m[1]);
}

const jobs = [];
for (const f of fs.readdirSync(srcDir)) {
  const id = idFromFile(f);
  if (!id) continue;
  if (onlyIds.size && !onlyIds.has(id)) continue;
  jobs.push({ id, src: path.join(srcDir, f) });
}
jobs.sort((a, b) => a.id.localeCompare(b.id, undefined, { numeric: true }));

if (!jobs.length) {
  console.error(`${srcDir} 里没找到 v_<单元>_<课>-s<序号>.png 形式的图`);
  process.exit(1);
}

let ok = 0;
for (const { id, src } of jobs) {
  if (!ID_OK.test(id)) { console.log(`  跳过 ${id}（id 格式不合法）`); continue; }
  if (!referenced.has(id)) { console.log(`  跳过 ${id}（课程里没有对应的 <Shot>，会变成孤儿图）`); continue; }
  const dest = path.join(SHOTS_DIR, `${id}.webp`);
  const before = fs.statSync(src).size;
  if (dry) { console.log(`  [dry] ${path.basename(src)} → ${id}.webp`); ok++; continue; }
  await sharp(src)
    .resize({ width: MAX, height: MAX, fit: 'inside', withoutEnlargement: true })
    .webp({ quality: QUALITY })
    .toFile(dest);
  // 清掉同 id 的其它扩展名残留，免得 <Shot> 探测到旧图
  for (const ext of ['png', 'jpg']) {
    const stale = path.join(SHOTS_DIR, `${id}.${ext}`);
    if (fs.existsSync(stale)) fs.unlinkSync(stale);
  }
  const after = fs.statSync(dest).size;
  console.log(`  ✓ ${id}.webp  ${(before/1024).toFixed(0)}KB → ${(after/1024).toFixed(0)}KB`);
  ok++;
}
console.log(`\n完成 ${ok}/${jobs.length}。跑 npm run shots:check 看剩余待拍。`);
