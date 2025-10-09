<script>
	import Form from './Form.svelte';

	let { categories } = $props();
</script>

<Form categories={categories} isEdit={false} />
