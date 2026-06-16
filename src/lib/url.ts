// 统一拼接 GitHub Pages 的 base 前缀。
// import.meta.env.BASE_URL 可能是 "/codeblox" 或 "/codeblox/"（取决于配置），
// 这里统一处理，保证结果只有一个斜杠。Vite 会在客户端 bundle 里内联 BASE_URL，
// 所以 .astro 与 Svelte 孤岛都能用这个函数。
const BASE = import.meta.env.BASE_URL;

/** 给站内路径加上 base 前缀。withBase('/foo') -> '/codeblox/foo'，withBase('/') -> '/codeblox/' */
export function withBase(path = '/'): string {
  const base = BASE.endsWith('/') ? BASE.slice(0, -1) : BASE;
  const p = path.startsWith('/') ? path : `/${path}`;
  return `${base}${p}`;
}
