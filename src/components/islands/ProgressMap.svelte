<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { orderedLessonIds } from '../../lib/catalog';
  import { lessonState, type LessonState } from '../../lib/progress';
  import { withBase } from '../../lib/url';
  import type { Catalog, CatalogUnit } from '../../lib/types';

  interface Props {
    catalog: Catalog;
  }
  let { catalog }: Props = $props();

  const units = catalog.units;
  const orderedIds = orderedLessonIds(catalog);

  let current = $state(0);
  let dir = $state(1);
  let toast = $state('');

  onMount(() => {
    store.hydrate();
    // 默认翻到“正在学”的那个单元
    const curId = store.active?.progress.currentLessonId;
    const unitId = curId ? catalog.lessons.find((l) => l.id === curId)?.unit : undefined;
    const idx = unitId ? units.findIndex((u) => u.id === unitId) : 0;
    current = idx >= 0 ? idx : 0;
  });

  const completed = $derived(store.active?.progress.completedLessons ?? {});
  const continueLesson = $derived(
    catalog.lessons.find((l) => l.id === store.active?.progress.currentLessonId) ??
      (store.active ? catalog.lessons.find((l) => !(l.id in completed)) : null),
  );

  const unit = $derived(units[current]);
  const unitLessons = $derived(catalog.lessons.filter((l) => l.unit === unit?.id));
  const doneInUnit = $derived(unitLessons.filter((l) => l.id in completed).length);

  function goTo(i: number) {
    if (i < 0 || i >= units.length || i === current) return;
    dir = i > current ? 1 : -1;
    current = i;
  }
  function unitDone(u: CatalogUnit): boolean {
    const ls = catalog.lessons.filter((l) => l.unit === u.id);
    return ls.length > 0 && ls.every((l) => l.id in completed);
  }

  // 触摸滑动
  let touchX = 0;
  function onTouchStart(e: TouchEvent) {
    touchX = e.changedTouches[0].clientX;
  }
  function onTouchEnd(e: TouchEvent) {
    const dx = e.changedTouches[0].clientX - touchX;
    if (dx > 45) goTo(current - 1);
    else if (dx < -45) goTo(current + 1);
  }

  function nodeClick(id: string, slug: string, st: LessonState) {
    if (st === 'locked') {
      toast = '先完成上一关哦 🔒';
      setTimeout(() => (toast = ''), 1500);
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

<div class="mx-auto max-w-2xl px-4 pb-8">
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

  <!-- 单元切换器：左右箭头 + 单元图标圆点 -->
  <div class="mb-4 flex items-center gap-2">
    <button
      type="button"
      class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white text-xl font-black text-slate-600 shadow-sm transition hover:bg-slate-50 disabled:opacity-30"
      disabled={current === 0}
      onclick={() => goTo(current - 1)}
      aria-label="上一个单元">‹</button
    >
    <div class="flex flex-1 items-center justify-center gap-1 overflow-x-auto">
      {#each units as u, i (u.id)}
        <button
          type="button"
          class={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-base transition ${
            i === current ? 'text-white shadow-sm' : unitDone(u) ? 'bg-emerald-100' : 'bg-slate-100 opacity-60 hover:opacity-100'
          }`}
          style={i === current ? `background:${u.color}` : ''}
          onclick={() => goTo(i)}
          aria-label={u.title}
          title={u.title}
        >
          {unitDone(u) && i !== current ? '✓' : u.emoji}
        </button>
      {/each}
    </div>
    <button
      type="button"
      class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white text-xl font-black text-slate-600 shadow-sm transition hover:bg-slate-50 disabled:opacity-30"
      disabled={current === units.length - 1}
      onclick={() => goTo(current + 1)}
      aria-label="下一个单元">›</button
    >
  </div>

  <!-- 当前单元这一“张幻灯片” -->
  <div class="overflow-hidden" ontouchstart={onTouchStart} ontouchend={onTouchEnd}>
    {#key current}
      <div class="slide-in" style={`--from:${dir * 48}px`}>
        <!-- 单元标题卡 -->
        <div class="rounded-3xl px-5 py-4" style={`background:${unit.color}22`}>
          <div class="flex items-center gap-3">
            <span class="text-4xl">{unit.emoji}</span>
            <div class="min-w-0 flex-1">
              <p class="text-xs font-bold text-slate-500">第 {current + 1} 单元 / 共 {units.length} 单元</p>
              <h2 class="truncate text-lg font-black text-slate-800">{unit.title}</h2>
            </div>
          </div>
          <div class="mt-3 flex items-center gap-2">
            <div class="h-2.5 flex-1 overflow-hidden rounded-full bg-white/70">
              <div
                class="h-full rounded-full transition-all duration-500"
                style={`width:${unitLessons.length ? (doneInUnit / unitLessons.length) * 100 : 0}%; background:${unit.color}`}
              ></div>
            </div>
            <span class="text-xs font-bold text-slate-500">{doneInUnit}/{unitLessons.length}</span>
          </div>
        </div>

        <!-- 这个单元的课程 -->
        <div class="mt-4 space-y-3">
          {#each unitLessons as l (l.id)}
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
      </div>
    {/key}
  </div>
</div>

{#if toast}
  <div class="fixed bottom-24 left-1/2 z-50 -translate-x-1/2 rounded-full bg-slate-800 px-5 py-2 font-bold text-white shadow-lg">
    {toast}
  </div>
{/if}

<style>
  .slide-in {
    animation: slidein 0.22s ease;
  }
  @keyframes slidein {
    from {
      opacity: 0;
      transform: translateX(var(--from, 48px));
    }
    to {
      opacity: 1;
      transform: none;
    }
  }
</style>
