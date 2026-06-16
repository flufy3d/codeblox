<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { orderedLessonIds } from '../../lib/catalog';
  import { lessonState, type LessonState } from '../../lib/progress';
  import { withBase } from '../../lib/url';
  import type { Catalog } from '../../lib/types';

  interface Props {
    catalog: Catalog;
  }
  let { catalog }: Props = $props();

  onMount(() => store.hydrate());

  const orderedIds = orderedLessonIds(catalog);
  const completed = $derived(store.active?.progress.completedLessons ?? {});
  const continueLesson = $derived(
    catalog.lessons.find((l) => l.id === store.active?.progress.currentLessonId) ??
      (store.active ? catalog.lessons.find((l) => !(l.id in completed)) : null),
  );

  let toast = $state('');

  function nodeClick(lessonId: string, slug: string, st: LessonState) {
    if (st === 'locked') {
      toast = '先完成上一关哦 🔒';
      setTimeout(() => (toast = ''), 1600);
      return;
    }
    window.location.href = withBase('/lessons/' + slug);
  }

  function circleClass(st: LessonState): string {
    if (st === 'completed') return 'bg-emerald-500 text-white';
    if (st === 'current') return 'bg-indigo-500 text-white ring-4 ring-indigo-200';
    if (st === 'locked') return 'bg-slate-200 text-slate-400';
    return 'bg-white text-slate-700 ring-2 ring-indigo-200';
  }
  function rowClass(st: LessonState): string {
    if (st === 'completed') return 'border-emerald-200 bg-emerald-50';
    if (st === 'current') return 'border-indigo-300 bg-white shadow-md';
    if (st === 'locked') return 'border-slate-100 bg-slate-50 opacity-70';
    return 'border-slate-200 bg-white';
  }
</script>

<div class="mx-auto max-w-2xl px-4 pb-16">
  {#if !store.active}
    <div class="my-4 rounded-3xl border-2 border-dashed border-indigo-200 bg-indigo-50 px-5 py-4 text-center text-indigo-700">
      👉 先点右上角 <b>「谁在学习？」</b> 创建一个小档案，开始你的冒险！
    </div>
  {:else if continueLesson}
    <a
      href={withBase('/lessons/' + continueLesson.slug)}
      class="my-4 flex items-center justify-between rounded-3xl bg-gradient-to-r from-indigo-500 to-fuchsia-500 px-5 py-4 text-white shadow-lg transition hover:brightness-105"
    >
      <span>
        <span class="block text-xs opacity-80">继续学习</span>
        <span class="text-lg font-black">{continueLesson.emoji} {continueLesson.title}</span>
      </span>
      <span class="text-2xl">▶</span>
    </a>
  {:else}
    <div class="my-4 rounded-3xl bg-emerald-50 px-5 py-4 text-center font-bold text-emerald-700">
      🎉 你已经完成了全部课程，太厉害啦！
    </div>
  {/if}

  {#each catalog.units as u (u.id)}
    <section class="mb-8">
      <div class="mb-3 flex items-center gap-3 rounded-2xl px-4 py-3" style={`background:${u.color}22`}>
        <span class="text-3xl">{u.emoji}</span>
        <div class="min-w-0">
          <h2 class="truncate font-black text-slate-800">{u.title}</h2>
          {#if u.subtitle}<p class="truncate text-sm text-slate-500">{u.subtitle}</p>{/if}
        </div>
      </div>

      <div class="space-y-3">
        {#each catalog.lessons.filter((l) => l.unit === u.id) as l (l.id)}
          {@const st = lessonState(l.id, orderedIds, completed)}
          <button
            type="button"
            class={`flex w-full items-center gap-4 rounded-2xl border-2 px-4 py-3 text-left transition ${rowClass(st)}`}
            onclick={() => nodeClick(l.id, l.slug, st)}
          >
            <span class={`flex h-12 w-12 shrink-0 items-center justify-center rounded-full text-xl font-black ${circleClass(st)}`}>
              {#if st === 'completed'}✓{:else if st === 'locked'}🔒{:else}{l.emoji}{/if}
            </span>
            <span class="min-w-0 flex-1">
              <span class="block truncate font-bold text-slate-800">{l.title}</span>
              <span class="text-xs text-slate-400">约 {l.estMinutes} 分钟 · +{l.xp} XP</span>
            </span>
            {#if st === 'current'}<span class="shrink-0 rounded-full bg-indigo-100 px-2 py-1 text-xs font-bold text-indigo-600">现在学</span>{/if}
            {#if st === 'completed'}<span class="shrink-0 text-emerald-500">★</span>{/if}
          </button>
        {/each}
      </div>
    </section>
  {/each}
</div>

{#if toast}
  <div class="fixed bottom-6 left-1/2 z-50 -translate-x-1/2 rounded-full bg-slate-800 px-5 py-2 font-bold text-white shadow-lg">
    {toast}
  </div>
{/if}
