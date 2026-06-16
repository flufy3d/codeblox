<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { QUIZ_PASS } from '../../lib/progress';
  import { withBase } from '../../lib/url';

  interface Props {
    lessonId: string;
    xp: number;
    taskIds: string[];
    hasQuiz: boolean;
    nextSlug?: string;
  }
  let { lessonId, xp, taskIds, hasQuiz, nextSlug }: Props = $props();

  onMount(() => store.hydrate());

  const tasksDone = $derived.by(() => {
    const ts = store.active?.progress.taskProgress[lessonId] ?? {};
    return taskIds.every((id) => ts[id]);
  });
  const quizOk = $derived(!hasQuiz || (store.active?.progress.quizScores[lessonId] ?? 0) >= QUIZ_PASS);
  const already = $derived(store.isComplete(lessonId));
  const canComplete = $derived(!!store.active && tasksDone && quizOk);

  let celebrating = $state(false);
  let resultMsg = $state('');

  // 撒花碎片（仅在庆祝时渲染，纯客户端，无水合不一致）
  const EMOJIS = ['🎉', '⭐', '🎊', '✨', '🟦', '🟨', '🟥', '🟩', '🟪'];
  const pieces = Array.from({ length: 28 }, (_, i) => ({
    emoji: EMOJIS[i % EMOJIS.length],
    left: Math.round(Math.random() * 100),
    delay: +(Math.random() * 0.8).toFixed(2),
    size: 16 + Math.round(Math.random() * 18),
  }));

  function complete() {
    const score = store.active?.progress.quizScores[lessonId] ?? 1;
    const r = store.completeLesson(lessonId, xp, score);
    const parts = [`+${r.awardedXp || xp} XP`];
    if (r.leveledUp) parts.push(`升到 ${r.level} 级！`);
    if (r.newBadges.length) parts.push('获得新徽章 🏅');
    resultMsg = parts.join(' · ');
    celebrating = true;
  }
</script>

<div class="my-6">
  {#if !store.active}
    <p class="rounded-2xl bg-amber-50 px-4 py-3 text-center font-bold text-amber-700">
      👉 先在右上角选一个学习者，才能完成这一课并获得 XP 哦！
    </p>
  {:else if already && !celebrating}
    <div class="flex flex-wrap items-center justify-center gap-3">
      <span class="rounded-full bg-emerald-100 px-4 py-2 font-bold text-emerald-700">✅ 这一课已经完成啦</span>
      <button type="button" class="rounded-full bg-slate-100 px-4 py-2 font-bold text-slate-600 hover:bg-slate-200" onclick={complete}>
        再做一遍
      </button>
      {#if nextSlug}
        <a href={withBase('/lessons/' + nextSlug)} class="rounded-full bg-indigo-500 px-5 py-2 font-bold text-white hover:bg-indigo-600">下一课 →</a>
      {/if}
    </div>
  {:else}
    <button
      type="button"
      class={`w-full rounded-2xl py-4 text-lg font-black text-white shadow-lg transition ${
        canComplete ? 'bg-emerald-500 hover:bg-emerald-600' : 'cursor-not-allowed bg-slate-300'
      }`}
      disabled={!canComplete}
      onclick={complete}
    >
      🎮 完成这一课！（+{xp} XP）
    </button>
    {#if !canComplete}
      <p class="mt-2 text-center text-sm text-slate-400">
        {!tasksDone ? '把上面的任务都打勾' : ''}{!tasksDone && !quizOk ? '，并且' : ''}{!quizOk ? '小测验答对至少 2/3' : ''}，就能完成啦
      </p>
    {/if}
  {/if}
</div>

{#if celebrating}
  <div class="fixed inset-0 z-50 flex items-center justify-center overflow-hidden bg-black/30">
    <div class="pop z-10 rounded-3xl bg-white px-8 py-6 text-center shadow-2xl">
      <div class="text-5xl">🎉</div>
      <p class="mt-2 text-xl font-black text-slate-800">完成啦！</p>
      <p class="mt-1 font-bold text-indigo-500">{resultMsg}</p>
      <div class="mt-4 flex flex-wrap justify-center gap-2">
        {#if nextSlug}
          <a href={withBase('/lessons/' + nextSlug)} class="rounded-full bg-indigo-500 px-5 py-2 font-bold text-white hover:bg-indigo-600">下一课 →</a>
        {/if}
        <a href={withBase('/')} class="rounded-full bg-slate-100 px-5 py-2 font-bold text-slate-600 hover:bg-slate-200">回到关卡地图</a>
        <button type="button" class="rounded-full px-3 py-2 text-sm font-bold text-slate-400 hover:text-slate-600" onclick={() => (celebrating = false)}>留在本课</button>
      </div>
    </div>
    {#each pieces as p, i (i)}
      <span class="confetti-piece" style={`left:${p.left}%; animation-delay:${p.delay}s; font-size:${p.size}px`}>{p.emoji}</span>
    {/each}
  </div>
{/if}

<style>
  .pop {
    animation: pop 0.4s cubic-bezier(0.2, 1.4, 0.4, 1);
  }
  @keyframes pop {
    from {
      transform: scale(0.6);
      opacity: 0;
    }
    to {
      transform: scale(1);
      opacity: 1;
    }
  }
  .confetti-piece {
    position: fixed;
    top: -10%;
    animation: fall 2.6s linear forwards;
    pointer-events: none;
  }
  @keyframes fall {
    to {
      transform: translateY(120vh) rotate(540deg);
      opacity: 0.9;
    }
  }
</style>
