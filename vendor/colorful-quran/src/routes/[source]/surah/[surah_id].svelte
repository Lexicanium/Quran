<script context="module" lang="ts">
	import type { IAya, ISurah } from '$contract/surah';
	import type { Load } from '@sveltejs/kit';
	import Icon from '@iconify/svelte';
	let basmalah = 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ';
	let basmalah01 = 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.';
	const getSurah = async (source, surah_id) => {
		return (await import(`../../../db/${source}/surah/${surah_id}.json`)).default as IAya[];
	};

	const getSurahDetail = async (surah_id) => {
		const listSurah = (await import(`../../../db/kemenag/list.json`)).default;
		return listSurah[surah_id - 1];
	};

	export const load: Load = async ({ params }) => {
		const surah = await getSurah(params.source, params.surah_id);
		const surahDetail = await getSurahDetail(params.surah_id);

		return {
			status: 200,
			props: {
				surah,
				surahDetail
			}
		};
	};
</script>

<script lang="ts">
	import TajweedView from '$component/TajweedView.svelte';
	import { Setting$ } from '$store/Setting';
	import { goto } from '$app/navigation';
	import Header from '$component/header.svelte';
	import ModalGoToAyat from '$component/modal/ModalGoToAyat.svelte';

	export let surah: IAya[];
	export let surahDetail: ISurah;

	let showModalGoToAyat = false;

	const saveLastReading = ({ detail: { sura_id, aya_number } }: { detail: IAya }) => {
		$Setting$.last_read_aya = aya_number.toString();
		$Setting$.last_read_surah = sura_id.toString();
		alert('berhasil menandai sebagai ayat terakhir dibaca');
	};

	const nextSurah = () => {
		let page = surahDetail.id + 1;
		goto(page.toString());
	};
	const prevSurah = () => {
		let page = surahDetail.id - 1;
		goto(page.toString());
	};
</script>

<Header />
<div
	class="flex justify-between items-center px-4 pt-4 pb-2 border-b dark:border-gray-700 sticky top-14 bg-white dark:bg-gray-800 z-10"
>
	<div class="w-8 cursor-pointer dark:text-gray-300" on:click={() => prevSurah()}>
		{#if surahDetail.id > 1}
			<Icon icon="ant-design:double-left-outlined" width="30" height="30" />
		{/if}
	</div>
	<div class="flex flex-col cursor-pointer" on:click={() => (showModalGoToAyat = true)}>
		<span class="text-lg font-bold text-center dark:text-gray-300">{surahDetail.surat_name}</span>
		<div class="flex">
			<span class="text-xs text-graySecond dark:text-gray-300">{surahDetail.surat_terjemahan}</span>
			<span class="text-xs text-graySecond dark:text-gray-300">
				&nbsp;{surahDetail.count_ayat} ayat</span
			>
		</div>
	</div>
	<div class="w-8 cursor-pointer dark:text-gray-300" on:click={() => nextSurah()}>
		{#if surahDetail.id < 114}
			<Icon icon="ant-design:double-right-outlined" width="30" height="30" />
		{/if}
	</div>
</div>
{#if surahDetail.id != 9}
	<div class="group flex flex-col items-center my-4 pb-2 dark:text-gray-300">
		<span
			class="mb-2 font-arab"
			style="font-size: {$Setting$.ukuranAyat}px; line-height: {Number($Setting$.ukuranAyat) +
				50}px ">{basmalah}</span
		>
		{#if $Setting$.showTranslate}
			<span class="text-xs" style="direction: ltr; font-size: {$Setting$.ukuranTerjemahan}px;"
				>{surahDetail.id == 1 ? '1. ' : ''}{basmalah01}</span
			>
		{/if}
	</div>
{/if}
<div class="p-4">
	<TajweedView {surah} {surahDetail} on:saveLastReading={saveLastReading} />
</div>

<ModalGoToAyat bind:show={showModalGoToAyat} max={surah.length} />
