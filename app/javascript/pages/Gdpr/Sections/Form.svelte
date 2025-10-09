<script>
	import { router, useForm } from '@inertiajs/svelte';

	let { questionnaire, section, isEdit = false } = $props();

	// Initialize form with Inertia's useForm
	const form = useForm({
		title: section?.title || '',
		description: section?.description || '',
		order_index: section?.order_index || 0
	});

	function handleSubmit(event) {
		event.preventDefault();

		if (isEdit) {
			$form.patch(`/gdpr/questionnaires/${questionnaire.id}/sections/${section.id}`, {
				onSuccess: () => {
					// Will redirect to questionnaire show page
				}
			});
		} else {
			$form.post(`/gdpr/questionnaires/${questionnaire.id}/sections`, {
				onSuccess: () => {
					// Will redirect to questionnaire show page
				}
			});
		}
	}

	function cancel() {
		router.visit(`/gdpr/questionnaires/${questionnaire.id}`);
	}
</script>

<div class="max-w-3xl mx-auto px-4 py-8">
	<div class="mb-8">
		<div class="flex items-center space-x-4 mb-4">
			<button
				onclick={cancel}
				class="text-gray-400 hover:text-gray-600"
			>
				<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
				</svg>
			</button>
			<div>
				<h1 class="text-3xl font-bold text-gray-900">
					{isEdit ? 'Edit Section' : 'New Section'}
				</h1>
				<p class="mt-1 text-sm text-gray-600">
					{questionnaire.title}
				</p>
			</div>
		</div>
		<p class="text-gray-600">
			{isEdit
				? 'Update this section of your questionnaire'
				: 'Add a new section to organize your questions'}
		</p>
	</div>

	<form onsubmit={handleSubmit} class="space-y-6">
		<!-- Title -->
		<div>
			<label for="title" class="block text-sm font-medium text-gray-700 mb-2">
				Section Title <span class="text-red-500">*</span>
			</label>
			<input
				id="title"
				type="text"
				bind:value={$form.title}
				required
				maxlength="500"
				placeholder="e.g., Data Processing Activities"
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
				class:border-red-300={$form.errors.title}
			/>
			{#if $form.errors.title}
				<p class="mt-1 text-sm text-red-600">{$form.errors.title}</p>
			{/if}
		</div>

		<!-- Description -->
		<div>
			<label for="description" class="block text-sm font-medium text-gray-700 mb-2">
				Description
			</label>
			<textarea
				id="description"
				bind:value={$form.description}
				rows="4"
				placeholder="Describe what this section covers..."
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-y"
				class:border-red-300={$form.errors.description}
			></textarea>
			{#if $form.errors.description}
				<p class="mt-1 text-sm text-red-600">{$form.errors.description}</p>
			{/if}
			<p class="mt-1 text-sm text-gray-500">
				This description will be shown to users taking the assessment
			</p>
		</div>

		<!-- Info Box -->
		<div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
			<div class="flex">
				<svg class="w-5 h-5 text-blue-400 mr-3 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
					<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
				</svg>
				<div class="text-sm text-blue-700">
					<p class="font-medium mb-1">Next steps:</p>
					<ul class="list-disc list-inside space-y-1">
						<li>Add questions to this section</li>
						<li>Configure answer choices for multiple choice questions</li>
						<li>Set up conditional logic (optional)</li>
					</ul>
				</div>
			</div>
		</div>

		<!-- Form Actions -->
		<div class="flex items-center justify-end space-x-3 pt-6 border-t border-gray-200">
			<button
				type="button"
				onclick={cancel}
				class="px-6 py-2 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50"
				disabled={$form.processing}
			>
				Cancel
			</button>
			<button
				type="submit"
				class="px-6 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
				disabled={$form.processing}
			>
				{#if $form.processing}
					<span class="flex items-center">
						<svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
							<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
							<path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
						</svg>
						Saving...
					</span>
				{:else}
					{isEdit ? 'Update Section' : 'Create Section'}
				{/if}
			</button>
		</div>
	</form>
</div>
