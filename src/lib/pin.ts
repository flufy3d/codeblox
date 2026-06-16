// ⚠️ 玩具级防护，不是真正的鉴权。
// PIN 的 salt+hash 就存在同一份 localStorage 里，孩子打开 DevTools 就能看到。
// 它只用来防止 8 岁的弟弟随手点进哥哥的档案、覆盖掉进度——威胁模型仅此而已。
import type { PinData } from './types';

function toHex(buf: ArrayBuffer): string {
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function randomSalt(): string {
  const a = new Uint8Array(8);
  crypto.getRandomValues(a);
  return toHex(a.buffer);
}

export async function hashPin(pin: string, salt: string): Promise<string> {
  const data = new TextEncoder().encode(salt + pin);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return toHex(digest);
}

export async function makePin(pin: string): Promise<PinData> {
  const salt = randomSalt();
  return { salt, hash: await hashPin(pin, salt) };
}

export async function verifyPin(pin: string, data: PinData): Promise<boolean> {
  return (await hashPin(pin, data.salt)) === data.hash;
}
