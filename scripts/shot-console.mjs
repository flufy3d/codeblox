#!/usr/bin/env node
/*
 * CodeBlox 截图控制台 —— 纯 Node，无第三方依赖。
 *
 * 用途：把「拍 Roblox Studio 截图」这件只有人能做的事，做到极度方便。
 *   它扫描所有课程里的 <Shot> 占位，给你一个待拍队列 + 每张的拍摄说明，
 *   你只需：看说明 → Win+Shift+S 截图（进剪贴板）→ 在网页里 Ctrl+V 粘贴 →（可选裁剪/画箭头）→ 回车保存。
 *   图片会自动压缩、命名、存到 public/shots/<id>.webp，并自动跳下一张。
 *
 * 用法：
 *   node scripts/shot-console.mjs            启动控制台（http://127.0.0.1:4444）
 *   node scripts/shot-console.mjs --check    只检查覆盖率（列出所有待拍 + 重复 id + 孤儿图），exit 0
 *   node scripts/shot-console.mjs --check --strict   有待拍则 exit 1（本地发布前自查用）
 *
 * 配套：另开一个终端跑 `npm run dev`（http://localhost:4321/codeblox/）做预览。
 */
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = process.cwd();
const LESSONS_DIR = path.join(ROOT, 'src', 'content', 'lessons');
const SHOTS_DIR = path.join(ROOT, 'public', 'shots');
const HTML_FILE = path.join(path.dirname(fileURLToPath(import.meta.url)), 'shot-console.html');
const PORT = 4444;
const HOST = '127.0.0.1';
const EXTS = ['webp', 'png', 'jpg'];
const MAX_BYTES = 8 * 1024 * 1024;
const ID_OK = /^[A-Za-z0-9][A-Za-z0-9._-]*$/; // 首字符必须字母/数字，挡住隐藏文件和路径穿越

fs.mkdirSync(SHOTS_DIR, { recursive: true });

// ───────────────────────── 扫描课程里的 <Shot> ─────────────────────────

function readFrontmatter(text) {
  const m = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  const fm = m ? m[1] : '';
  const id = (fm.match(/^id:\s*"?([^"\n\r]+?)"?\s*$/m) || [])[1] || '';
  let title = (fm.match(/^title:\s*(.+?)\s*$/m) || [])[1] || '';
  title = title.replace(/^["']|["']$/g, '');
  return { id, title };
}

function scanFile(file) {
  const text = fs.readFileSync(path.join(LESSONS_DIR, file), 'utf8');
  const { id: lessonFmId, title: lessonTitle } = readFrontmatter(text);
  const slug = file.replace(/\.mdx$/, '');
  const lines = text.split(/\r?\n/);
  const shots = [];
  let heading = '';
  const tagRe = /<Shot\b([^>]*?)\/>/g;
  for (const line of lines) {
    const h = line.match(/^#{2,3}\s+(.+?)\s*$/);
    if (h) heading = h[1];
    tagRe.lastIndex = 0;
    let mm;
    while ((mm = tagRe.exec(line))) {
      const attrs = mm[1];
      const id = (attrs.match(/\bid\s*=\s*"([^"]*)"/) || [])[1] || '';
      const capture = (attrs.match(/\bcapture\s*=\s*"([^"]*)"/) || [])[1] || '';
      const alt = (attrs.match(/\balt\s*=\s*"([^"]*)"/) || [])[1] || '';
      shots.push({ id, capture, alt, section: heading, lessonFile: file, slug, lessonFmId, lessonTitle });
    }
  }
  return shots;
}

function existingExt(id) {
  for (const ext of EXTS) {
    if (fs.existsSync(path.join(SHOTS_DIR, `${id}.${ext}`))) return ext;
  }
  return null;
}

function buildQueue() {
  const files = fs.readdirSync(LESSONS_DIR).filter((f) => f.endsWith('.mdx')).sort();
  const all = [];
  files.forEach((file, fileIndex) => {
    scanFile(file).forEach((s, inFileIndex) => all.push({ ...s, fileIndex, inFileIndex }));
  });

  const counts = {};
  for (const s of all) counts[s.id] = (counts[s.id] || 0) + 1;
  for (const s of all) {
    s.existingExt = existingExt(s.id);
    s.status = s.existingExt ? 'done' : 'pending';
    s.duplicate = counts[s.id] > 1;
  }

  // 待拍优先；同状态按文件顺序、文件内出现顺序
  all.sort((a, b) => {
    if (a.status !== b.status) return a.status === 'pending' ? -1 : 1;
    if (a.fileIndex !== b.fileIndex) return a.fileIndex - b.fileIndex;
    return a.inFileIndex - b.inFileIndex;
  });

  const done = all.filter((s) => s.status === 'done').length;
  const duplicates = [...new Set(all.filter((s) => s.duplicate).map((s) => s.id))];
  return { shots: all, total: all.length, done, pending: all.length - done, duplicates };
}

function orphanShots(referencedIds) {
  if (!fs.existsSync(SHOTS_DIR)) return [];
  return fs
    .readdirSync(SHOTS_DIR)
    .filter((f) => EXTS.some((e) => f.toLowerCase().endsWith('.' + e)))
    .filter((f) => !referencedIds.has(f.replace(/\.(webp|png|jpg)$/i, '')));
}

// ───────────────────────── --check 覆盖率模式 ─────────────────────────

function runCheck() {
  const q = buildQueue();
  console.log(`\n📸 截图覆盖率：已拍 ${q.done} / 共 ${q.total}，待拍 ${q.pending}\n`);

  const byFile = {};
  for (const s of q.shots) if (s.status === 'pending') (byFile[s.lessonFile] ||= []).push(s);
  const files = Object.keys(byFile).sort();
  if (files.length === 0) {
    console.log('🎉 全部拍完！');
  } else {
    for (const f of files) {
      console.log(`  ${f}  (${byFile[f].length} 待拍)`);
      for (const s of byFile[f]) console.log(`    · ${s.id}  ${s.capture || '(无说明)'}`);
    }
  }

  if (q.duplicates.length) console.log(`\n⚠️  重复 id（必须唯一，否则会撞图）：${q.duplicates.join(', ')}`);

  const orphans = orphanShots(new Set(q.shots.map((s) => s.id)));
  if (orphans.length) console.log(`\n🗑️  孤儿图片（课程里已无对应 <Shot>，可删）：${orphans.join(', ')}`);

  const strict = process.argv.includes('--strict');
  process.exit(strict && q.pending > 0 ? 1 : 0);
}

// ───────────────────────── HTTP 服务 ─────────────────────────

function sendJson(res, code, obj) {
  res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(obj));
}

function extFromContentType(ct = '') {
  if (ct.includes('png')) return 'png';
  if (ct.includes('jpeg') || ct.includes('jpg')) return 'jpg';
  return 'webp';
}

function contentTypeOf(ext) {
  return ext === 'png' ? 'image/png' : ext === 'jpg' ? 'image/jpeg' : 'image/webp';
}

function serveHtml(res) {
  fs.readFile(HTML_FILE, (err, buf) => {
    if (err) {
      res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('读取 shot-console.html 失败：' + err.message);
      return;
    }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(buf);
  });
}

function serveShot(res, pathname) {
  const name = path.basename(pathname); // 只取文件名，挡穿越
  const file = path.join(SHOTS_DIR, name);
  if (!path.resolve(file).startsWith(path.resolve(SHOTS_DIR) + path.sep)) {
    res.writeHead(400);
    res.end();
    return;
  }
  fs.readFile(file, (err, buf) => {
    if (err) {
      res.writeHead(404);
      res.end();
      return;
    }
    const ext = path.extname(name).slice(1).toLowerCase();
    res.writeHead(200, { 'Content-Type': contentTypeOf(ext), 'Cache-Control': 'no-store' });
    res.end(buf);
  });
}

function handleUpload(req, res, rawId) {
  const id = ID_OK.test(rawId) ? rawId : null;
  if (!id) return sendJson(res, 400, { ok: false, error: '非法 id' });

  const ext = extFromContentType(req.headers['content-type']);
  const target = path.join(SHOTS_DIR, `${id}.${ext}`);
  if (!path.resolve(target).startsWith(path.resolve(SHOTS_DIR) + path.sep)) {
    return sendJson(res, 400, { ok: false, error: '路径不合法' });
  }

  const chunks = [];
  let size = 0;
  let aborted = false;
  req.on('data', (c) => {
    size += c.length;
    if (size > MAX_BYTES) {
      aborted = true;
      sendJson(res, 413, { ok: false, error: '图片过大（>8MB）' });
      req.destroy();
      return;
    }
    chunks.push(c);
  });
  req.on('end', () => {
    if (aborted) return;
    const buf = Buffer.concat(chunks);
    if (buf.length === 0) return sendJson(res, 400, { ok: false, error: '空数据' });
    try {
      fs.writeFileSync(target, buf);
      // 删除同 id 的其它扩展名残留，避免 <Shot> 探测到旧图
      for (const e of EXTS) {
        if (e === ext) continue;
        const p = path.join(SHOTS_DIR, `${id}.${e}`);
        if (fs.existsSync(p)) fs.unlinkSync(p);
      }
      console.log(`  ✓ 已保存 ${id}.${ext}  (${(buf.length / 1024).toFixed(0)} KB)`);
      sendJson(res, 200, { ok: true, ext, bytes: buf.length });
    } catch (e) {
      sendJson(res, 500, { ok: false, error: String(e) });
    }
  });
  req.on('error', () => {
    if (!aborted) sendJson(res, 500, { ok: false, error: '传输出错' });
  });
}

function startServer() {
  const server = http.createServer((req, res) => {
    let pathname = '/';
    try {
      pathname = decodeURIComponent(new URL(req.url, `http://${HOST}:${PORT}`).pathname);
    } catch {
      pathname = req.url || '/';
    }

    if (req.method === 'GET' && pathname === '/') return serveHtml(res);
    if (req.method === 'GET' && pathname === '/api/queue') {
      try {
        return sendJson(res, 200, buildQueue());
      } catch (e) {
        return sendJson(res, 500, { error: String(e) });
      }
    }
    if (req.method === 'GET' && pathname.startsWith('/shots/')) return serveShot(res, pathname);
    if (req.method === 'POST' && pathname.startsWith('/api/shot/')) {
      return handleUpload(req, res, pathname.slice('/api/shot/'.length));
    }

    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('not found');
  });

  server.listen(PORT, HOST, () => {
    const q = buildQueue();
    console.log('\n📸  CodeBlox 截图控制台已启动');
    console.log(`    控制台： http://${HOST}:${PORT}`);
    console.log('    预览：   http://localhost:4321/codeblox/   （另开终端跑 npm run dev）');
    console.log(`    进度：   已拍 ${q.done} / 共 ${q.total}，待拍 ${q.pending}`);
    if (q.duplicates.length) console.log(`    ⚠️  重复 id：${q.duplicates.join(', ')}`);
    console.log('\n    流程：看说明 → Win+Shift+S 截图 → 切到控制台 Ctrl+V → 回车保存（会自动跳下一张）\n');
  });
  server.on('error', (e) => {
    if (e.code === 'EADDRINUSE') console.error(`\n端口 ${PORT} 被占用，可能控制台已在运行。\n`);
    else console.error(e);
    process.exit(1);
  });
}

// ───────────────────────── 入口 ─────────────────────────

if (process.argv.includes('--check')) runCheck();
else startServer();
