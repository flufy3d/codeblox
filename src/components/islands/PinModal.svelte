<script lang="ts">
  interface Props {
    title?: string;
    error?: string;
    onsubmit: (pin: string) => void;
    oncancel: () => void;
  }
  let { title = '请输入 4 位密码', error = '', onsubmit, oncancel }: Props = $props();

  let pin = $state('');
  const dots = $derived('●'.repeat(pin.length) + '○'.repeat(4 - pin.length));

  function press(d: string) {
    if (pin.length >= 4) return;
    pin += d;
    if (pin.length === 4) {
      const p = pin;
      pin = ''; // 重置以便重试
      onsubmit(p);
    }
  }
  function back() {
    pin = pin.slice(0, -1);
  }
</script>

<div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" role="dialog" aria-modal="true">
  <div class="w-full max-w-xs rounded-3xl bg-white p-6 text-center shadow-2xl">
    <p class="mb-1 text-lg font-bold text-slate-800">{title}</p>
    <p class="mb-4 select-none text-3xl tracking-[0.3em] text-indigo-500">{dots}</p>
    {#if error}<p class="mb-3 text-sm font-bold text-rose-500">{error}</p>{/if}
    <div class="grid grid-cols-3 gap-2">
      {#each ['1', '2', '3', '4', '5', '6', '7', '8', '9'] as d}
        <button
          type="button"
          class="rounded-2xl bg-slate-100 py-3 text-xl font-bold text-slate-700 hover:bg-indigo-100"
          onclick={() => press(d)}>{d}</button
        >
      {/each}
      <button
        type="button"
        class="rounded-2xl bg-slate-100 py-3 text-sm font-bold text-slate-500 hover:bg-slate-200"
        onclick={oncancel}>取消</button
      >
      <button
        type="button"
        class="rounded-2xl bg-slate-100 py-3 text-xl font-bold text-slate-700 hover:bg-indigo-100"
        onclick={() => press('0')}>0</button
      >
      <button
        type="button"
        class="rounded-2xl bg-slate-100 py-3 text-xl font-bold text-slate-500 hover:bg-slate-200"
        onclick={back}>⌫</button
      >
    </div>
  </div>
</div>
