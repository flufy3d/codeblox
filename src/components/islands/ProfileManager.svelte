<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { makePin } from '../../lib/pin';
  import { AVATARS } from '../../lib/i18n';
  import PinModal from './PinModal.svelte';

  onMount(() => store.hydrate());

  let editingId = $state<string | null>(null);
  let editName = $state('');
  let pinSetId = $state<string | null>(null);
  let confirmDeleteId = $state<string | null>(null);

  const deleteTarget = $derived(confirmDeleteId ? store.data.profiles[confirmDeleteId] : null);

  function startRename(id: string) {
    const p = store.data.profiles[id];
    if (!p) return;
    editingId = id;
    editName = p.name;
  }
  function saveRename(id: string) {
    const p = store.data.profiles[id];
    if (p) store.renameProfile(id, editName.trim() || p.name, p.avatar);
    editingId = null;
  }
  function cycleAvatar(id: string) {
    const p = store.data.profiles[id];
    if (!p) return;
    const i = AVATARS.indexOf(p.avatar);
    store.renameProfile(id, p.name, AVATARS[(i + 1) % AVATARS.length]);
  }
  async function onSetPin(pin: string) {
    if (pinSetId) {
      store.setPin(pinSetId, await makePin(pin));
      pinSetId = null;
    }
  }
  function doDelete() {
    if (confirmDeleteId) {
      store.removeProfile(confirmDeleteId);
      confirmDeleteId = null;
    }
  }
</script>

<div class="space-y-3">
  {#if store.profileList.length === 0}
    <p class="rounded-2xl bg-slate-50 px-4 py-6 text-center text-slate-400">
      还没有档案，点右上角「谁在学习？」创建一个吧～
    </p>
  {/if}
  {#each store.profileList as p (p.id)}
    <div class="flex flex-wrap items-center gap-3 rounded-2xl border-2 border-slate-200 bg-white px-4 py-3">
      <button
        type="button"
        class="flex h-11 w-11 items-center justify-center rounded-full bg-indigo-100 text-xl"
        title="点一下换头像"
        onclick={() => cycleAvatar(p.id)}>{p.avatar}</button
      >
      {#if editingId === p.id}
        <input class="flex-1 rounded-xl border-2 border-indigo-300 px-3 py-1 outline-none" bind:value={editName} maxlength="12" />
        <button type="button" class="rounded-full bg-indigo-500 px-3 py-1 text-sm font-bold text-white" onclick={() => saveRename(p.id)}>保存</button>
      {:else}
        <span class="flex-1 font-bold text-slate-800">
          {p.name}
          {#if store.active?.id === p.id}<span class="ml-1 text-xs text-emerald-500">（当前）</span>{/if}
        </span>
        <button type="button" class="text-sm font-bold text-slate-400 hover:text-indigo-500" onclick={() => startRename(p.id)}>改名</button>
      {/if}
      {#if p.pin}
        <button type="button" class="text-sm font-bold text-slate-400 hover:text-rose-500" onclick={() => store.setPin(p.id, null)}>🔓 取消密码</button>
      {:else}
        <button type="button" class="text-sm font-bold text-slate-400 hover:text-indigo-500" onclick={() => (pinSetId = p.id)}>🔒 设密码</button>
      {/if}
      <button type="button" class="text-sm font-bold text-slate-300 hover:text-rose-500" onclick={() => (confirmDeleteId = p.id)}>删除</button>
    </div>
  {/each}
</div>

{#if pinSetId}
  <PinModal title="设置 4 位密码" onsubmit={onSetPin} oncancel={() => (pinSetId = null)} />
{/if}

{#if confirmDeleteId}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
    <div class="w-full max-w-sm rounded-3xl bg-white p-6 text-center shadow-2xl">
      <p class="font-bold text-slate-800">确定删除「{deleteTarget?.name}」吗？</p>
      <p class="mt-1 text-sm text-slate-500">这个档案的全部进度会被清除，无法恢复。</p>
      <div class="mt-4 flex justify-center gap-2">
        <button type="button" class="rounded-full bg-rose-500 px-4 py-2 font-bold text-white hover:bg-rose-600" onclick={doDelete}>删除</button>
        <button type="button" class="rounded-full bg-slate-100 px-4 py-2 font-bold text-slate-600 hover:bg-slate-200" onclick={() => (confirmDeleteId = null)}>取消</button>
      </div>
    </div>
  </div>
{/if}
