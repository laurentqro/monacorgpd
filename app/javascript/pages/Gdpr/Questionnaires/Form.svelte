<script>
	import { router, useForm } from '@inertiajs/svelte';

	let { questionnaire, categories, isEdit = false } = $props();

	// Initialize form with Inertia's useForm
	const form = useForm({
		title: questionnaire?.title || '',
		description: questionnaire?.description || '',
		category: questionnaire?.category || 'gdpr',
		status: questionnaire?.status || 'draft'
	});

	function handleSubmit(event) {
		event.preventDefault();

		if (isEdit) {
			$form.patch(`/gdpr/questionnaires/${questionnaire.id}`, {
				onSuccess: () => {
					// Will redirect to show page
				}
			});
		} else {
			$form.post('/gdpr/questionnaires', {
				onSuccess: () => {
					// Will redirect to show page
				}
			});
		}
	}

	function cancel() {
		if (isEdit) {
			router.visit(`/gdpr/questionnaires/${questionnaire.id}`);
		} else {
			router.visit('/gdpr/questionnaires');
		}
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
			<h1 class="text-3xl font-bold text-gray-900">
				{isEdit ? 'Edit Questionnaire' : 'New Questionnaire'}
			</h1>
		</div>
		<p class="text-gray-600">
			{isEdit
				? 'Update your Monaco RGPD compliance questionnaire'
				: 'Create a new questionnaire for Monaco Law 1.565 compliance'}
		</p>
	</div>

	<form onsubmit={handleSubmit} class="space-y-6">
		<!-- Title -->
		<div>
			<label for="title" class="block text-sm font-medium text-gray-700 mb-2">
				Title <span class="text-red-500">*</span>
			</label>
			<input
				id="title"
				type="text"
				bind:value={$form.title}
				required
				maxlength="500"
				placeholder="e.g., Monaco RGPD Compliance Assessment"
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
				placeholder="Describe the purpose and scope of this questionnaire..."
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-y"
				class:border-red-300={$form.errors.description}
			></textarea>
			{#if $form.errors.description}
				<p class="mt-1 text-sm text-red-600">{$form.errors.description}</p>
			{/if}
		</div>

		<!-- Category -->
		<div>
			<label for="category" class="block text-sm font-medium text-gray-700 mb-2">
				Category <span class="text-red-500">*</span>
			</label>
			<select
				id="category"
				bind:value={$form.category}
				required
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
				class:border-red-300={$form.errors.category}
			>
				{#each categories as category}
					<option value={category.value}>
						{category.label}
					</option>
				{/each}
			</select>
			{#if $form.errors.category}
				<p class="mt-1 text-sm text-red-600">{$form.errors.category}</p>
			{/if}
			<p class="mt-1 text-sm text-gray-500">
				Select the compliance area this questionnaire addresses
			</p>
		</div>

		<!-- Status (only for edit mode) -->
		{#if isEdit}
			<div>
				<label for="status" class="block text-sm font-medium text-gray-700 mb-2">
					Status
				</label>
				<select
					id="status"
					bind:value={$form.status}
					class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
				>
					<option value="draft">Draft</option>
					<option value="published">Published</option>
					<option value="archived">Archived</option>
				</select>
				<p class="mt-1 text-sm text-gray-500">
					Published questionnaires can be taken by users
				</p>
			</div>
		{/if}

		<!-- Info Box -->
		<div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
			<div class="flex">
				<svg class="w-5 h-5 text-blue-400 mr-3 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
					<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
				</svg>
				<div class="text-sm text-blue-700">
					<p class="font-medium mb-1">Next steps after creating:</p>
					<ul class="list-disc list-inside space-y-1">
						<li>Add sections to organize your questions</li>
						<li>Create questions within each section</li>
						<li>Set up logic rules for conditional sections (optional)</li>
						<li>Publish when ready for users to complete</li>
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
					{isEdit ? 'Update Questionnaire' : 'Create Questionnaire'}
				{/if}
			</button>
		</div>
	</form>
</div>
