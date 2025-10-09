<script>
	import Form from './Form.svelte';

	let { questionnaire, categories } = $props();
</script>

<Form questionnaire={questionnaire} categories={categories} isEdit={true} />
