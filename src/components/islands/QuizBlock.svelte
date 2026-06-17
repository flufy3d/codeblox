<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { scoreQuiz } from '../../lib/progress';
  import { speak, toggleSpeak } from '../../lib/tts';
  import { UI } from '../../lib/i18n';

  interface Q {
    q: string;
    type: 'single' | 'multi';
    options: string[];
    answer: number | number[];
    explain?: string;
  }
  interface Props {
    lessonId: string;
    quiz: Q[];
  }
  let { lessonId, quiz }: Props = $props();

  onMount(() => store.hydrate());

  let answers = $state<(number | number[] | undefined)[]>(
    quiz.map((q) => (q.type === 'multi' ? [] : undefined)),
  );
  let submitted = $state(false);
  let qEls: HTMLElement[] = []; // 每道题的文字元素，朗读时高亮

  const correctList = $derived(quiz.map((q) => q.answer));
  const score = $derived(scoreQuiz(answers, correctList));
  const correctCount = $derived(Math.round(score * quiz.length));

  function isChosen(qi: number, oi: number): boolean {
    const a = answers[qi];
    return Array.isArray(a) ? a.includes(oi) : a === oi;
  }
  function pick(qi: number, oi: number) {
    if (submitted) return;
    if (quiz[qi].type === 'multi') {
      const cur = (answers[qi] as number[]) ?? [];
      answers[qi] = cur.includes(oi) ? cur.filter((x) => x !== oi) : [...cur, oi];
    } else {
      answers[qi] = oi;
    }
  }
  function optionClass(qi: number, oi: number): string {
    if (!submitted) {
      return isChosen(qi, oi) ? 'border-indigo-400 bg-indigo-50' : 'border-slate-200 bg-white hover:border-indigo-200';
    }
    const correct = quiz[qi].answer;
    const isCorrect = Array.isArray(correct) ? correct.includes(oi) : correct === oi;
    if (isCorrect) return 'border-emerald-400 bg-emerald-50';
    if (isChosen(qi, oi)) return 'border-rose-300 bg-rose-50';
    return 'border-slate-200 bg-white opacity-60';
  }
  function submit() {
    submitted = true;
    store.setQuizScore(lessonId, score);
  }
  function retry() {
    submitted = false;
    answers = quiz.map((q) => (q.type === 'multi' ? [] : undefined));
  }
</script>

{#if quiz.length}
  <div class="my-4 space-y-5">
    {#each quiz as q, qi (qi)}
      <div class="rounded-2xl border-2 border-slate-100 bg-slate-50 p-4">
        <div class="mb-3 flex items-start gap-1">
          <p bind:this={qEls[qi]} class="flex-1 font-bold text-slate-800">
            {qi + 1}. {q.q}
            {#if q.type === 'multi'}<span class="ml-1 text-xs font-normal text-slate-400">（可多选）</span>{/if}
          </p>
          <button
            type="button"
            class="tts-btn shrink-0"
            aria-label={UI.ttsListen}
            onclick={() => toggleSpeak(qEls[qi], q.q)}>🔊</button
          >
        </div>
        <div class="space-y-2">
          {#each q.options as opt, oi (oi)}
            <div class="flex items-center gap-2">
              <button
                type="button"
                class={`block flex-1 rounded-xl border-2 px-4 py-2 text-left text-slate-700 transition ${optionClass(qi, oi)}`}
                onclick={() => pick(qi, oi)}
              >
                {opt}
              </button>
              <button
                type="button"
                class="tts-btn shrink-0"
                aria-label={UI.ttsListen}
                onclick={() => speak(opt)}>🔊</button
              >
            </div>
          {/each}
        </div>
        {#if submitted && q.explain}
          <p class="mt-2 text-sm text-slate-500">💡 {q.explain}</p>
        {/if}
      </div>
    {/each}

    {#if !submitted}
      <button
        type="button"
        class="rounded-full bg-indigo-500 px-6 py-2 font-bold text-white hover:bg-indigo-600"
        onclick={submit}
      >
        提交答案
      </button>
    {:else}
      <div class="flex items-center gap-3">
        <span class="font-black text-slate-800">答对 {correctCount} / {quiz.length} 题</span>
        {#if score >= 2 / 3}
          <span class="rounded-full bg-emerald-100 px-3 py-1 text-sm font-bold text-emerald-700">很棒！可以完成这一课了 ✅</span>
        {:else}
          <span class="rounded-full bg-amber-100 px-3 py-1 text-sm font-bold text-amber-700">再多答对一点点～</span>
        {/if}
        <button type="button" class="rounded-full bg-slate-100 px-4 py-1 text-sm font-bold text-slate-600 hover:bg-slate-200" onclick={retry}>再做一次</button>
      </div>
    {/if}
  </div>
{/if}
