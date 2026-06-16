<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { verifyPin } from '../../lib/pin';
  import { AVATARS } from '../../lib/i18n';
  import PinModal from './PinModal.svelte';

  onMount(() => store.hydrate());

  let open = $state(false);
  let creating = $state(false);
  let newName = $state('');
  let newAvatar = $state(AVATARS[0]);

  let pinTargetId = $state<string | null>(null);
  let pinError = $state('');

  function chooseProfile(id: string) {
    const p = store.data.profiles[id];
    if (!p) return;
    if (p.pin) {
      pinTargetId = id;
      pinError = '';
    } else {
      store.setActive(id);
      open = false;
    }
  }

  async function onPinSubmit(pin: string) {
    const p = pinTargetId ? store.data.profiles[pinTargetId] : null;
    if (p?.pin && (await verifyPin(pin, p.pin))) {
      store.setActive(p.id);
      pinTargetId = null;
      open = false;
    } else {
      pinError = '密码不对，再试一次';
    }
  }

  function createProfile() {
    const name = newName.trim() || '小创造者';
    store.addProfile(name, newAvatar);
    creating = false;
    open = false;
    newName = '';
    newAvatar = AVATARS[0];
  }
</script>

<div class="relative">
  {#if store.active}
    <button
      type="button"
      class="flex items-center gap-2 rounded-full border-2 border-slate-200 bg-white py-1 pl-1 pr-3 font-bold text-slate-700 hover:border-indigo-300"
      onclick={() => (open = !open)}
    >
      <span class="flex h-8 w-8 items-center justify-center rounded-full bg-indigo-100 text-lg">{store.active.avatar}</span>
      <span class="max-w-24 truncate">{store.active.name}</span>
      <span class="text-xs text-slate-400">▾</span>
    </button>
  {:else}
    <button
      type="button"
      class="animate-pulse rounded-full bg-indigo-500 px-4 py-2 font-bold text-white hover:bg-indigo-600"
      onclick={() => (open = true)}
    >
      👤 谁在学习？
    </button>
  {/if}

  {#if open}
    <!-- 点击外部关闭 -->
    <button type="button" class="fixed inset-0 z-30 cursor-default" aria-label="关闭" onclick={() => (open = false)}></button>
    <div class="absolute right-0 z-40 mt-2 w-64 rounded-3xl border-2 border-slate-100 bg-white p-3 shadow-xl">
      <p class="px-2 pb-2 text-sm font-bold text-slate-400">谁在学习？</p>

      <ul class="space-y-1">
        {#each store.profileList as p (p.id)}
          <li>
            <button
              type="button"
              class={`flex w-full items-center gap-2 rounded-2xl px-2 py-2 text-left hover:bg-slate-50 ${store.active?.id === p.id ? 'bg-indigo-50' : ''}`}
              onclick={() => chooseProfile(p.id)}
            >
              <span class="flex h-9 w-9 items-center justify-center rounded-full bg-indigo-100 text-lg">{p.avatar}</span>
              <span class="flex-1 truncate font-bold text-slate-700">{p.name}</span>
              {#if p.pin}<span class="text-xs text-slate-400">🔒</span>{/if}
              {#if store.active?.id === p.id}<span class="text-emerald-500">✓</span>{/if}
            </button>
          </li>
        {/each}
      </ul>

      {#if creating}
        <div class="mt-2 rounded-2xl bg-slate-50 p-3">
          <input
            class="mb-2 w-full rounded-xl border-2 border-slate-200 px-3 py-2 text-slate-700 outline-none focus:border-indigo-400"
            placeholder="起个名字"
            maxlength="12"
            bind:value={newName}
          />
          <div class="mb-2 grid grid-cols-6 gap-1">
            {#each AVATARS as a}
              <button
                type="button"
                class={`rounded-lg py-1 text-lg hover:bg-white ${newAvatar === a ? 'bg-white ring-2 ring-indigo-400' : ''}`}
                onclick={() => (newAvatar = a)}>{a}</button
              >
            {/each}
          </div>
          <button type="button" class="w-full rounded-xl bg-indigo-500 py-2 font-bold text-white hover:bg-indigo-600" onclick={createProfile}>创建</button>
        </div>
      {:else}
        <button
          type="button"
          class="mt-2 w-full rounded-2xl border-2 border-dashed border-slate-200 py-2 font-bold text-slate-500 hover:border-indigo-300 hover:text-indigo-500"
          onclick={() => (creating = true)}
        >
          ＋ 新建小档案
        </button>
      {/if}
    </div>
  {/if}
</div>

{#if pinTargetId}
  <PinModal
    title={`输入「${store.data.profiles[pinTargetId]?.name ?? ''}」的密码`}
    error={pinError}
    onsubmit={onPinSubmit}
    oncancel={() => (pinTargetId = null)}
  />
{/if}
