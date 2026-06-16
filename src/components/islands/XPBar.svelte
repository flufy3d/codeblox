<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { levelInfo } from '../../lib/progress';

  onMount(() => store.hydrate());

  const info = $derived(levelInfo(store.active?.progress.xp ?? 0));
  const streak = $derived(store.active?.progress.streak.count ?? 0);
</script>

{#if store.active}
  <div class="flex items-center gap-2">
    <span class="rounded-full bg-indigo-100 px-2 py-1 text-xs font-black text-indigo-700">
      Lv.{info.level}
    </span>
    <div class="hidden sm:block" title={`${info.into}/${info.needed} XP`}>
      <div class="h-3 w-24 overflow-hidden rounded-full bg-slate-200">
        <div
          class="h-full rounded-full bg-gradient-to-r from-indigo-400 to-fuchsia-400 transition-all duration-500"
          style={`width:${Math.round(info.pct * 100)}%`}
        ></div>
      </div>
    </div>
    {#if streak > 0}
      <span
        class="flex items-center gap-0.5 rounded-full bg-orange-100 px-2 py-1 text-xs font-black text-orange-600"
        title="连续打卡">🔥{streak}</span
      >
    {/if}
  </div>
{/if}
