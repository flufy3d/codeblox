<script lang="ts">
  // 「我的档案」页的朗读设置：语速 / 选音 / 试听。读写当前档案（每个孩子各一份），
  // 与课程页共用同一个 store 和发声器（src/lib/tts.ts）。
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';
  import { speak, listZhVoices } from '../../lib/tts';
  import { UI } from '../../lib/i18n';

  const SPEEDS = [
    { label: '🐢 慢', rate: 0.7 },
    { label: '🙂 正常', rate: 0.9 },
    { label: '🐇 快', rate: 1.1 },
  ];
  const SAMPLE = '你好，我们一起来做游戏吧';

  let voices = $state<SpeechSynthesisVoice[]>([]);
  let supported = $state(true);

  onMount(() => {
    store.hydrate();
    if (typeof window === 'undefined' || !('speechSynthesis' in window)) {
      supported = false;
      return;
    }
    const refresh = () => (voices = listZhVoices());
    refresh(); // 有些浏览器要等 voiceschanged 才有列表
    window.speechSynthesis.addEventListener('voiceschanged', refresh);
    return () => window.speechSynthesis.removeEventListener('voiceschanged', refresh);
  });

  const active = $derived(store.active);
  const rate = $derived(store.ttsSettings.rate);
  const voiceURI = $derived(store.ttsSettings.voiceURI ?? '');
</script>

{#if !active}
  <p class="rounded-2xl bg-slate-50 px-4 py-6 text-center text-slate-400">
    请先在上面选择一个学习者，再来调整朗读设置。
  </p>
{:else}
  <div class="space-y-4">
    <p class="text-sm text-slate-500">
      正在为「<span class="font-bold text-slate-700">{active.name}</span>」设置，每个孩子各自一份。
    </p>

    <!-- 语速 -->
    <div>
      <p class="mb-2 font-bold text-slate-700">{UI.ttsSpeed}</p>
      <div class="flex flex-wrap gap-2">
        {#each SPEEDS as s (s.rate)}
          <button
            type="button"
            class={`rounded-full border-2 px-4 py-2 font-bold transition ${
              rate === s.rate
                ? 'border-indigo-500 bg-indigo-50 text-indigo-700'
                : 'border-slate-200 bg-white text-slate-600 hover:border-indigo-200'
            }`}
            onclick={() => store.setTtsRate(s.rate)}>{s.label}</button
          >
        {/each}
      </div>
    </div>

    <!-- 选音 -->
    <div>
      <p class="mb-2 font-bold text-slate-700">{UI.ttsVoice}</p>
      {#if !supported}
        <p class="text-sm text-amber-700">这个浏览器不支持朗读，建议用 Edge 或 Chrome。</p>
      {:else}
        <select
          class="w-full max-w-md rounded-xl border-2 border-slate-200 bg-white px-3 py-2 text-slate-700"
          onchange={(e) => store.setTtsVoice((e.currentTarget as HTMLSelectElement).value || null)}
        >
          <option value="" selected={voiceURI === ''}>{UI.ttsVoiceAuto}（推荐）</option>
          {#each voices as v (v.voiceURI)}
            <option value={v.voiceURI} selected={voiceURI === v.voiceURI}>{v.name}</option>
          {/each}
        </select>
        {#if voices.length === 0}
          <p class="mt-1 text-sm text-amber-700">{UI.ttsNoVoice}</p>
        {/if}
      {/if}
    </div>

    <!-- 试听 -->
    <button
      type="button"
      class="rounded-full bg-indigo-500 px-5 py-2 font-bold text-white hover:bg-indigo-600"
      onclick={() => speak(SAMPLE)}>🔊 试听</button
    >

    <p class="text-xs text-slate-400">
      Windows 上用 Edge 浏览器，可用到更自然的免费中文语音（名字带 Online / Natural）。这些设置会随这个档案的导出/导入一起保存。
    </p>
  </div>
{/if}
