<script lang="ts">
	import Modal from '$component/Modal.svelte';
	import { Setting$ } from '$store/Setting';
	import Icon from '@iconify/svelte';

	export let show = false;

	const themeMode = () => {
		$Setting$.theme = $Setting$.theme == 'dark' ? 'light' : 'dark';
	};

	const copyUrl = () => {
		let url = window.location.href;
		navigator.clipboard.writeText(url);
		alert('Url berhasil disalin');
	};

	const changeUkuranAyat = (e) => {
		$Setting$.ukuranAyat = e.target.value;
	};
	const changeUkuranTerjemahan = (e) => {
		$Setting$.ukuranTerjemahan = e.target.value;
	};

	const hideTranslate = () => {
		$Setting$.showTranslate = !$Setting$.showTranslate;
	};
</script>

{#if show}
	<Modal on:dismiss={() => (show = false)} title="Pengaturan">
		<div class="border-b py-2 flex mb-3 cursor-pointer" on:click={themeMode}>
			<div class="w-12 flex justify-center">
				<Icon icon="fluent:dark-theme-24-filled" width="20" height="20" />
			</div>
			<span>Tema {$Setting$.theme == 'dark' ? 'terang' : 'gelap'}</span>
		</div>
		<div class="border-b py-2 flex mb-3 cursor-pointer" on:click={copyUrl}>
			<div class="w-12 flex justify-center">
				<Icon icon="ant-design:copy-outlined" width="20" height="20" />
			</div>
			<span>Salin tautan surah ini</span>
		</div>
		<div class="border-b py-2 flex mb-3 cursor-pointer" on:click={hideTranslate}>
			<div class="w-12 flex justify-center">
				<Icon icon="bi:translate" width="20" height="20" />
			</div>
			<span>{$Setting$.showTranslate ? 'Hilangkan' : 'Tampilkan'} terjemahan</span>
		</div>
		<div class="border-b py-2 flex mb-3">
			<div class="w-12 flex justify-center">
				<Icon icon="bx:bx-font-size" width="20" height="20" />
			</div>
			<div class="block">
				<span>Ukuran Ayat</span>
				<input
					type="range"
					min="10"
					max="40"
					class="w-full"
					on:change={changeUkuranAyat}
					value={$Setting$.ukuranAyat}
				/>
				<span class="text-xs text-graySecond">{$Setting$.ukuranAyat} px</span>
			</div>
		</div>
		<div class="border-b py-2 flex mb-3 cursor-pointer">
			<div class="w-12 flex justify-center">
				<Icon icon="bx:bx-font-size" width="20" height="20" />
			</div>
			<div class="block">
				<span>Ukuran Terjemahan</span>
				<input
					type="range"
					min="10"
					max="40"
					class="w-full"
					on:change={changeUkuranTerjemahan}
					value={$Setting$.ukuranTerjemahan}
				/>
				<span class="text-xs text-graySecond">{$Setting$.ukuranTerjemahan} px</span>
			</div>
		</div>
	</Modal>
{/if}
