<script lang="ts">
  import { onMount } from 'svelte';
  import { store } from '../../lib/store.svelte';

  interface Task {
    id: string;
    label: string;
  }
  interface Props {
    lessonId: string;
    tasks: Task[];
  }
  let { lessonId, tasks }: Props = $props();

  onMount(() => store.hydrate());

  const state = $derived(store.active?.progress.taskProgress[lessonId] ?? {});

  function toggle(id: string, checked: boolean) {
    store.setTask(lessonId, id, checked);
  }
</script>

{#if tasks.length}
  <ul class="my-4 space-y-2">
    {#each tasks as t (t.id)}
      <li>
        <label
          class="flex cursor-pointer items-start gap-3 rounded-2xl border-2 border-slate-200 bg-white px-4 py-3 transition hover:border-indigo-300"
        >
          <input
            type="checkbox"
            class="mt-0.5 h-5 w-5 accent-indigo-500"
            checked={!!state[t.id]}
            disabled={!store.active}
            onchange={(e) => toggle(t.id, e.currentTarget.checked)}
          />
          <span class={`flex-1 ${state[t.id] ? 'text-slate-400 line-through' : 'text-slate-700'}`}>{t.label}</span>
        </label>
      </li>
    {/each}
  </ul>
  {#if !store.active}
    <p class="text-sm text-slate-400">👆 先在右上角选一个学习者，才能记录进度哦。</p>
  {/if}
{/if}
