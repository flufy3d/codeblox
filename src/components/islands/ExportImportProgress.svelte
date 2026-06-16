<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import type { ProfileExport, Profile } from '../../lib/types';

  onMount(() => store.hydrate());

  let msg = $state('');
  let pending = $state<Profile | null>(null); // 同 id 已存在，等用户选覆盖/副本

  function today() {
    return new Date().toISOString().slice(0, 10);
  }
  function download(filename: string, data: unknown) {
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
  }

  function exportActive() {
    const p = store.active;
    if (!p) {
      msg = '先选择一个学习者';
      return;
    }
    download(`codeblox-${p.name}-${today()}.json`, store.exportProfile(p.id));
    msg = `已导出「${p.name}」的进度 ✅`;
  }

  function exportAll() {
    download(`codeblox-全部档案-${today()}.json`, store.exportAll());
    msg = '已导出全部档案 ✅';
  }

  async function onFile(e: Event) {
    const input = e.currentTarget as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    try {
      const data = JSON.parse(await file.text()) as ProfileExport;
      if (data.format !== 'codeblox-progress') {
        msg = '这看起来不是 CodeBlox 的备份文件';
      } else if (data.profiles) {
        for (const p of Object.values(data.profiles)) store.importProfile(p, false);
        msg = '已导入全部档案 ✅';
      } else if (data.profile) {
        if (store.data.profiles[data.profile.id]) {
          pending = data.profile; // 让用户选覆盖还是副本
        } else {
          store.importProfile(data.profile, false);
          msg = '已导入档案 ✅';
        }
      } else {
        msg = '备份文件里没有档案数据';
      }
    } catch {
      msg = '文件读取失败，请确认是正确的 .json 备份';
    }
    input.value = '';
  }

  function resolve(asCopy: boolean) {
    if (!pending) return;
    store.importProfile(pending, asCopy);
    msg = asCopy ? '已作为副本导入 ✅' : '已覆盖导入 ✅';
    pending = null;
  }
</script>

<div class="space-y-3">
  <div class="flex flex-wrap gap-2">
    <button type="button" class="rounded-full bg-indigo-500 px-4 py-2 font-bold text-white hover:bg-indigo-600" onclick={exportActive}>
      ⬇️ 导出当前进度
    </button>
    <button type="button" class="rounded-full bg-slate-100 px-4 py-2 font-bold text-slate-600 hover:bg-slate-200" onclick={exportAll}>
      ⬇️ 导出全部档案
    </button>
    <label class="cursor-pointer rounded-full bg-slate-100 px-4 py-2 font-bold text-slate-600 hover:bg-slate-200">
      ⬆️ 导入备份
      <input type="file" accept="application/json,.json" class="hidden" onchange={onFile} />
    </label>
  </div>
  {#if msg}<p class="text-sm font-bold text-emerald-600">{msg}</p>{/if}
  <p class="text-xs text-slate-400">
    进度保存在这台设备的浏览器里。换设备或清理缓存前，记得先「导出」备份；到新设备再「导入」即可。
  </p>
</div>

{#if pending}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
    <div class="w-full max-w-sm rounded-3xl bg-white p-6 text-center shadow-2xl">
      <p class="font-bold text-slate-800">已经有一个同名档案「{pending.name}」</p>
      <p class="mt-1 text-sm text-slate-500">你想怎么处理这份备份？</p>
      <div class="mt-4 flex justify-center gap-2">
        <button type="button" class="rounded-full bg-rose-500 px-4 py-2 font-bold text-white hover:bg-rose-600" onclick={() => resolve(false)}>覆盖它</button>
        <button type="button" class="rounded-full bg-indigo-500 px-4 py-2 font-bold text-white hover:bg-indigo-600" onclick={() => resolve(true)}>另存为副本</button>
        <button type="button" class="rounded-full bg-slate-100 px-4 py-2 font-bold text-slate-600 hover:bg-slate-200" onclick={() => (pending = null)}>取消</button>
      </div>
    </div>
  </div>
{/if}
