<script>
	import Form from './Form.svelte';

	let { questionnaire, section } = $props();
</script>

<Form questionnaire={questionnaire} section={section} isEdit={false} />
