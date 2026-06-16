<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { allBadgeDefs } from '../../lib/badges';
  import type { Catalog } from '../../lib/types';

  interface Props {
    catalog: Catalog;
  }
  let { catalog }: Props = $props();

  onMount(() => store.hydrate());

  const defs = allBadgeDefs(catalog);
  const earned = $derived(new Set(store.active?.progress.badges ?? []));
</script>

<div class="mx-auto max-w-2xl px-4">
  {#if !store.active}
    <p class="rounded-2xl bg-amber-50 px-4 py-3 text-center font-bold text-amber-700">先选择一个学习者，看看 TA 的徽章墙～</p>
  {:else}
    <p class="mb-4 text-center text-slate-500">
      已收集 <b class="text-indigo-600">{earned.size}</b> / {defs.length} 枚徽章
    </p>
    <div class="grid grid-cols-2 gap-3 sm:grid-cols-3">
      {#each defs as b (b.id)}
        {@const has = earned.has(b.id)}
        <div
          class={`flex flex-col items-center rounded-3xl border-2 p-4 text-center transition ${
            has ? 'border-amber-200 bg-amber-50' : 'border-slate-100 bg-slate-50'
          }`}
        >
          <span class={`text-4xl ${has ? '' : 'opacity-30 grayscale'}`}>{b.emoji}</span>
          <span class={`mt-2 font-black ${has ? 'text-slate-800' : 'text-slate-400'}`}>{b.name}</span>
          <span class="mt-1 text-xs text-slate-400">{has ? '已获得 ✅' : b.desc}</span>
        </div>
      {/each}
    </div>
  {/if}
</div>
