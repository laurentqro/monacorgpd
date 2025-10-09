<script>
	import { router } from '@inertiajs/svelte';

	let { questionnaire, section, questions } = $props();

	function createQuestion() {
		router.visit(`/gdpr/questionnaires/${questionnaire.id}/sections/${section.id}/questions/new`);
	}

	function editQuestion(questionId) {
		router.visit(`/gdpr/questionnaires/${questionnaire.id}/sections/${section.id}/questions/${questionId}/edit`);
	}

	function deleteQuestion(questionId) {
		if (confirm('Are you sure you want to delete this question? This action cannot be undone.')) {
			router.delete(`/gdpr/questionnaires/${questionnaire.id}/sections/${section.id}/questions/${questionId}`);
		}
	}

	function backToQuestionnaire() {
		router.visit(`/gdpr/questionnaires/${questionnaire.id}`);
	}

	function getQuestionTypeLabel(type) {
		const labels = {
			single_choice: 'Single Choice',
			multiple_choice: 'Multiple Choice',
			text_short: 'Short Text',
			text_long: 'Long Text',
			yes_no: 'Yes/No',
			rating_scale: 'Rating Scale'
		};
		return labels[type] || type;
	}

	function getQuestionTypeBadgeClass(type) {
		const classes = {
			single_choice: 'bg-blue-100 text-blue-800',
			multiple_choice: 'bg-purple-100 text-purple-800',
			text_short: 'bg-green-100 text-green-800',
			text_long: 'bg-green-100 text-green-800',
			yes_no: 'bg-yellow-100 text-yellow-800',
			rating_scale: 'bg-pink-100 text-pink-800'
		};
		return classes[type] || 'bg-gray-100 text-gray-800';
	}
</script>

<div class="max-w-7xl mx-auto px-4 py-8">
	<!-- Header -->
	<div class="mb-8">
		<div class="flex items-center space-x-4 mb-4">
			<button
				onclick={backToQuestionnaire}
				class="text-gray-400 hover:text-gray-600"
			>
				<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
				</svg>
			</button>
			<div class="flex-1">
				<h1 class="text-3xl font-bold text-gray-900">{section.title}</h1>
				<p class="mt-1 text-sm text-gray-600">
					Questions for {questionnaire.title}
				</p>
			</div>
			<button
				onclick={createQuestion}
				class="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
			>
				<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
				</svg>
				Add Question
			</button>
		</div>
	</div>

	<!-- Questions List -->
	{#if questions && questions.length > 0}
		<div class="bg-white rounded-lg shadow-sm border border-gray-200">
			<div class="divide-y divide-gray-200">
				{#each questions as question, index (question.id)}
					<div class="p-6 hover:bg-gray-50 transition-colors">
						<div class="flex items-start justify-between">
							<div class="flex-1">
								<div class="flex items-center space-x-3 mb-2">
									<span class="flex-shrink-0 inline-flex items-center justify-center w-8 h-8 rounded-full bg-gray-200 text-gray-700 text-sm font-medium">
										{index + 1}
									</span>
									<div class="flex items-center space-x-2">
										<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {getQuestionTypeBadgeClass(question.question_type)}">
											{getQuestionTypeLabel(question.question_type)}
										</span>
										{#if question.is_required}
											<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
												Required
											</span>
										{/if}
									</div>
								</div>

								<h3 class="text-lg font-medium text-gray-900 mb-2">
									{question.question_text}
								</h3>

								{#if question.help_text}
									<p class="text-sm text-gray-600 mb-3">
										{question.help_text}
									</p>
								{/if}

								<!-- Answer Choices Preview (for single/multiple choice) -->
								{#if question.answer_choices && question.answer_choices.length > 0}
									<div class="mt-3 pl-4 border-l-2 border-gray-200">
										<p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-2">
											Answer Choices
										</p>
										<ul class="space-y-1">
											{#each question.answer_choices.slice(0, 3) as choice}
												<li class="text-sm text-gray-700">
													• {choice.choice_text}
													{#if choice.score}
														<span class="text-gray-500">(score: {choice.score})</span>
													{/if}
												</li>
											{/each}
											{#if question.answer_choices.length > 3}
												<li class="text-sm text-gray-500">
													+{question.answer_choices.length - 3} more choices
												</li>
											{/if}
										</ul>
									</div>
								{/if}

								<!-- Settings Preview (for rating scale) -->
								{#if question.question_type === 'rating_scale' && question.settings}
									<div class="mt-3 flex items-center space-x-4 text-sm text-gray-600">
										<span class="flex items-center">
											<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
											</svg>
											Range: {question.settings.min || 1} - {question.settings.max || 10}
										</span>
										<span>Weight: {question.weight}</span>
									</div>
								{:else}
									<div class="mt-3 text-sm text-gray-600">
										Weight: {question.weight}
									</div>
								{/if}
							</div>

							<!-- Actions -->
							<div class="flex items-center space-x-2 ml-4">
								<button
									onclick={() => editQuestion(question.id)}
									class="inline-flex items-center px-3 py-1.5 bg-blue-100 text-blue-700 text-sm font-medium rounded hover:bg-blue-200"
								>
									<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
									</svg>
									Edit
								</button>
								<button
									onclick={() => deleteQuestion(question.id)}
									class="inline-flex items-center px-3 py-1.5 bg-red-100 text-red-700 text-sm font-medium rounded hover:bg-red-200"
								>
									<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
									</svg>
									Delete
								</button>
							</div>
						</div>
					</div>
				{/each}
			</div>
		</div>
	{:else}
		<!-- Empty State -->
		<div class="bg-white rounded-lg shadow-sm border border-gray-200 text-center py-12">
			<svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
			</svg>
			<h3 class="mt-2 text-sm font-medium text-gray-900">No questions</h3>
			<p class="mt-1 text-sm text-gray-500">Get started by creating your first question.</p>
			<div class="mt-6">
				<button
					onclick={createQuestion}
					class="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
				>
					<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
					</svg>
					Add Question
				</button>
			</div>
		</div>
	{/if}

	<!-- Info Box -->
	<div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
		<div class="flex">
			<svg class="w-5 h-5 text-blue-400 mr-3 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
				<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
			</svg>
			<div class="text-sm text-blue-700">
				<p class="font-medium mb-1">Question Types:</p>
				<ul class="list-disc list-inside space-y-1">
					<li><strong>Single Choice:</strong> User selects one option</li>
					<li><strong>Multiple Choice:</strong> User can select multiple options</li>
					<li><strong>Short/Long Text:</strong> Free text input</li>
					<li><strong>Yes/No:</strong> Simple binary choice</li>
					<li><strong>Rating Scale:</strong> Numeric rating (e.g., 1-5)</li>
				</ul>
			</div>
		</div>
	</div>
</div>
