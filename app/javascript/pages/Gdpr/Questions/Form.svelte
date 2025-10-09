<script>
	import { router, useForm } from '@inertiajs/svelte';

	let { questionnaire, section, question, questionTypes, isEdit = false } = $props();

	// Initialize form with Inertia's useForm
	const form = useForm({
		question_text: question?.question_text || '',
		question_type: question?.question_type || 'single_choice',
		help_text: question?.help_text || '',
		is_required: question?.is_required || false,
		weight: question?.weight || 1.0,
		settings: question?.settings || { min: 1, max: 5 }
	});

	// Answer choices for single/multiple choice questions
	let answerChoices = $state(
		question?.answer_choices?.map(ac => ({
			id: ac.id,
			text: ac.choice_text,
			score: ac.score || 0
		})) || [
			{ text: '', score: 0 },
			{ text: '', score: 0 }
		]
	);

	// Derived state for conditional rendering
	let needsAnswerChoices = $derived(
		$form.question_type === 'single_choice' || $form.question_type === 'multiple_choice'
	);

	let needsRatingSettings = $derived($form.question_type === 'rating_scale');

	function addAnswerChoice() {
		answerChoices = [...answerChoices, { text: '', score: 0 }];
	}

	function removeAnswerChoice(index) {
		if (answerChoices.length > 1) {
			answerChoices = answerChoices.filter((_, i) => i !== index);
		}
	}

	function handleSubmit(event) {
		event.preventDefault();

		const data = {
			question: {
				question_text: $form.question_text,
				question_type: $form.question_type,
				help_text: $form.help_text,
				is_required: $form.is_required,
				weight: $form.weight,
				settings: needsRatingSettings ? $form.settings : {}
			},
			answer_choices: needsAnswerChoices
				? answerChoices.filter(ac => ac.text.trim() !== '')
				: []
		};

		if (isEdit) {
			router.patch(
				`/gdpr/questionnaires/${questionnaire.id}/sections/${section.id}/questions/${question.id}`,
				data,
				{
					onSuccess: () => {
						// Will redirect to questions index
					}
				}
			);
		} else {
			router.post(
				`/gdpr/questionnaires/${questionnaire.id}/sections/${section.id}/questions`,
				data,
				{
					onSuccess: () => {
						// Will redirect to questions index
					}
				}
			);
		}
	}

	function cancel() {
		router.visit(`/gdpr/questionnaires/${questionnaire.id}/sections/${section.id}/questions`);
	}
</script>

<div class="max-w-4xl mx-auto px-4 py-8">
	<div class="mb-8">
		<div class="flex items-center space-x-4 mb-4">
			<button onclick={cancel} class="text-gray-400 hover:text-gray-600">
				<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M15 19l-7-7 7-7"
					/>
				</svg>
			</button>
			<div>
				<h1 class="text-3xl font-bold text-gray-900">
					{isEdit ? 'Edit Question' : 'New Question'}
				</h1>
				<p class="mt-1 text-sm text-gray-600">
					{questionnaire.title} → {section.title}
				</p>
			</div>
		</div>
	</div>

	<form onsubmit={handleSubmit} class="space-y-6">
		<!-- Question Type -->
		<div>
			<label for="question_type" class="block text-sm font-medium text-gray-700 mb-2">
				Question Type <span class="text-red-500">*</span>
			</label>
			<select
				id="question_type"
				bind:value={$form.question_type}
				required
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
			>
				{#each questionTypes as type}
					<option value={type.value}>
						{type.label} - {type.description}
					</option>
				{/each}
			</select>
		</div>

		<!-- Question Text -->
		<div>
			<label for="question_text" class="block text-sm font-medium text-gray-700 mb-2">
				Question Text <span class="text-red-500">*</span>
			</label>
			<textarea
				id="question_text"
				bind:value={$form.question_text}
				required
				rows="3"
				placeholder="e.g., How many employees does your organization have?"
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-y"
				class:border-red-300={$form.errors.question_text}
			></textarea>
			{#if $form.errors.question_text}
				<p class="mt-1 text-sm text-red-600">{$form.errors.question_text}</p>
			{/if}
		</div>

		<!-- Help Text -->
		<div>
			<label for="help_text" class="block text-sm font-medium text-gray-700 mb-2">
				Help Text (Optional)
			</label>
			<input
				id="help_text"
				type="text"
				bind:value={$form.help_text}
				placeholder="Additional guidance for users"
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
			/>
			<p class="mt-1 text-sm text-gray-500">
				Optional hint text to help users understand the question
			</p>
		</div>

		<!-- Answer Choices (for single/multiple choice) -->
		{#if needsAnswerChoices}
			<div class="bg-gray-50 border border-gray-200 rounded-lg p-6">
				<div class="flex items-center justify-between mb-4">
					<h3 class="text-lg font-medium text-gray-900">Answer Choices</h3>
					<button
						type="button"
						onclick={addAnswerChoice}
						class="inline-flex items-center px-3 py-1.5 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
					>
						<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M12 4v16m8-8H4"
							/>
						</svg>
						Add Choice
					</button>
				</div>

				<div class="space-y-3">
					{#each answerChoices as choice, index (index)}
						<div class="flex items-center space-x-3">
							<span
								class="flex-shrink-0 w-8 h-8 flex items-center justify-center bg-gray-200 rounded-full text-sm font-medium"
							>
								{index + 1}
							</span>
							<input
								type="text"
								bind:value={choice.text}
								placeholder="Choice text"
								required
								class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
							/>
							<input
								type="number"
								bind:value={choice.score}
								step="0.1"
								placeholder="Score"
								class="w-24 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
							/>
							{#if answerChoices.length > 1}
								<button
									type="button"
									onclick={() => removeAnswerChoice(index)}
									class="flex-shrink-0 p-2 text-red-600 hover:bg-red-50 rounded-lg"
								>
									<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
										/>
									</svg>
								</button>
							{/if}
						</div>
					{/each}
				</div>
			</div>
		{/if}

		<!-- Rating Scale Settings -->
		{#if needsRatingSettings}
			<div class="bg-gray-50 border border-gray-200 rounded-lg p-6">
				<h3 class="text-lg font-medium text-gray-900 mb-4">Rating Scale Settings</h3>
				<div class="grid grid-cols-2 gap-4">
					<div>
						<label for="min" class="block text-sm font-medium text-gray-700 mb-2">
							Minimum Value
						</label>
						<input
							id="min"
							type="number"
							bind:value={$form.settings.min}
							required
							min="0"
							class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
						/>
					</div>
					<div>
						<label for="max" class="block text-sm font-medium text-gray-700 mb-2">
							Maximum Value
						</label>
						<input
							id="max"
							type="number"
							bind:value={$form.settings.max}
							required
							min="1"
							class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
						/>
					</div>
				</div>
			</div>
		{/if}

		<!-- Required & Weight -->
		<div class="grid grid-cols-2 gap-6">
			<div>
				<label class="flex items-center space-x-3 cursor-pointer">
					<input
						type="checkbox"
						bind:checked={$form.is_required}
						class="w-5 h-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
					/>
					<span class="text-sm font-medium text-gray-700">Required Question</span>
				</label>
				<p class="mt-1 text-sm text-gray-500">Users must answer this question</p>
			</div>

			<div>
				<label for="weight" class="block text-sm font-medium text-gray-700 mb-2">
					Weight (for scoring)
				</label>
				<input
					id="weight"
					type="number"
					bind:value={$form.weight}
					step="0.1"
					min="0"
					class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
				/>
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
						<svg
							class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
							fill="none"
							viewBox="0 0 24 24"
						>
							<circle
								class="opacity-25"
								cx="12"
								cy="12"
								r="10"
								stroke="currentColor"
								stroke-width="4"
							></circle>
							<path
								class="opacity-75"
								fill="currentColor"
								d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
							></path>
						</svg>
						Saving...
					</span>
				{:else}
					{isEdit ? 'Update Question' : 'Create Question'}
				{/if}
			</button>
		</div>
	</form>
</div>
