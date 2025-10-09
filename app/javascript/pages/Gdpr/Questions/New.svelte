<script>
	import Form from './Form.svelte';

	let { questionnaire, section, question, questionTypes } = $props();
</script>

<Form
	questionnaire={questionnaire}
	section={section}
	question={question}
	questionTypes={questionTypes}
	isEdit={false}
/>
