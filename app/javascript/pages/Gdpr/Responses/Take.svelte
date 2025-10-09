<script>
	import { router } from '@inertiajs/svelte';
	import QuestionRenderer from '../../../components/gdpr/QuestionRenderer.svelte';

	let { questionnaire, response } = $props();

	let currentSectionIndex = $state(0);
	let answers = $state(new Map());
	let isSaving = $state(false);

	// Initialize answers from response if editing
	$effect(() => {
		if (response?.answers) {
			const answerMap = new Map();
			response.answers.forEach(answer => {
				answerMap.set(answer.question_id, answer.answer_value);
			});
			answers = answerMap;
		}
	});

	let currentSection = $derived(questionnaire.sections[currentSectionIndex]);
	let isFirstSection = $derived(currentSectionIndex === 0);
	let isLastSection = $derived(currentSectionIndex === questionnaire.sections.length - 1);

	let sectionProgress = $derived(() => {
		if (!currentSection) return 0;
		const answeredCount = currentSection.questions.filter(q =>
			answers.has(q.id) && answers.get(q.id) !== null && answers.get(q.id) !== undefined
		).length;
		return (answeredCount / currentSection.questions.length) * 100;
	});

	let overallProgress = $derived(() => {
		const totalQuestions = questionnaire.sections.reduce((sum, section) =>
			sum + section.questions.length, 0
		);
		const answeredCount = Array.from(answers.values()).filter(v =>
			v !== null && v !== undefined
		).length;
		return totalQuestions > 0 ? (answeredCount / totalQuestions) * 100 : 0;
	});

	function handleAnswerChange(questionId, value) {
		answers.set(questionId, value);
		saveProgress();
	}

	function saveProgress() {
		if (isSaving) return;

		isSaving = true;

		const answersArray = Array.from(answers.entries()).map(([questionId, answerValue]) => ({
			question_id: questionId,
			answer_value: answerValue
		}));

		router.patch(`/gdpr/responses/${response.id}`, {
			answers: answersArray
		}, {
			preserveState: true,
			preserveScroll: true,
			onFinish: () => {
				isSaving = false;
			}
		});
	}

	function previousSection() {
		if (!isFirstSection) {
			currentSectionIndex--;
			window.scrollTo({ top: 0, behavior: 'smooth' });
		}
	}

	function nextSection() {
		if (!isLastSection) {
			currentSectionIndex++;
			window.scrollTo({ top: 0, behavior: 'smooth' });
		}
	}

	function submitResponse() {
		if (confirm('Are you sure you want to submit this assessment? Once submitted, you cannot make further changes.')) {
			router.post(`/gdpr/responses/${response.id}/submit`, {}, {
				onSuccess: () => {
					// Will redirect to response show page
				}
			});
		}
	}

	function isQuestionAnswered(question) {
		const answer = answers.get(question.id);
		return answer !== null && answer !== undefined;
	}

	function canProceedToNext() {
		if (!currentSection) return false;
		const requiredQuestions = currentSection.questions.filter(q => q.is_required);
		return requiredQuestions.every(q => isQuestionAnswered(q));
	}
</script>

<div class="min-h-screen bg-gray-50">
	<!-- Header with Progress -->
	<div class="bg-white border-b border-gray-200 sticky top-0 z-10">
		<div class="max-w-4xl mx-auto px-4 py-4">
			<div class="flex items-center justify-between mb-3">
				<h1 class="text-xl font-semibold text-gray-900">{questionnaire.title}</h1>
				{#if isSaving}
					<span class="text-sm text-gray-500 flex items-center">
						<svg class="animate-spin h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24">
							<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
							<path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
						</svg>
						Saving...
					</span>
				{:else}
					<span class="text-sm text-gray-500">Auto-saved</span>
				{/if}
			</div>

			<!-- Overall Progress Bar -->
			<div>
				<div class="flex items-center justify-between text-sm text-gray-600 mb-1">
					<span>Overall Progress</span>
					<span>{Math.round(overallProgress())}%</span>
				</div>
				<div class="w-full bg-gray-200 rounded-full h-2">
					<div
						class="bg-blue-600 h-2 rounded-full transition-all duration-300"
						style="width: {overallProgress()}%"
					></div>
				</div>
			</div>
		</div>
	</div>

	<div class="max-w-4xl mx-auto px-4 py-8">
		<!-- Section Navigation -->
		<div class="mb-6">
			<div class="flex items-center space-x-2 overflow-x-auto pb-2">
				{#each questionnaire.sections as section, index}
					<button
						onclick={() => currentSectionIndex = index}
						class="flex-shrink-0 px-4 py-2 rounded-lg text-sm font-medium transition-colors
							{index === currentSectionIndex
								? 'bg-blue-600 text-white'
								: 'bg-white text-gray-700 hover:bg-gray-50 border border-gray-200'
							}"
					>
						{index + 1}. {section.title}
					</button>
				{/each}
			</div>
		</div>

		<!-- Current Section -->
		{#if currentSection}
			<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
				<div class="mb-6">
					<h2 class="text-2xl font-bold text-gray-900 mb-2">
						{currentSection.title}
					</h2>
					{#if currentSection.description}
						<p class="text-gray-600">{currentSection.description}</p>
					{/if}
				</div>

				<!-- Section Progress -->
				<div class="mb-6">
					<div class="flex items-center justify-between text-sm text-gray-600 mb-1">
						<span>Section Progress</span>
						<span>{Math.round(sectionProgress())}%</span>
					</div>
					<div class="w-full bg-gray-200 rounded-full h-1.5">
						<div
							class="bg-green-600 h-1.5 rounded-full transition-all duration-300"
							style="width: {sectionProgress()}%"
						></div>
					</div>
				</div>

				<!-- Questions -->
				<div class="space-y-8">
					{#each currentSection.questions as question, index (question.id)}
						<div class="pb-8 border-b border-gray-100 last:border-0 last:pb-0">
							<div class="flex items-start mb-3">
								<span class="flex-shrink-0 inline-flex items-center justify-center w-8 h-8 rounded-full bg-gray-100 text-gray-600 text-sm font-medium mr-3">
									{index + 1}
								</span>
								<div class="flex-1">
									<h3 class="text-lg font-medium text-gray-900">
										{question.question_text}
										{#if question.is_required}
											<span class="text-red-500 ml-1">*</span>
										{/if}
									</h3>
									{#if question.help_text}
										<p class="mt-1 text-sm text-gray-500">{question.help_text}</p>
									{/if}
								</div>
							</div>

							<div class="ml-11">
								<QuestionRenderer
									{question}
									value={answers.get(question.id)}
									onchange={(value) => handleAnswerChange(question.id, value)}
								/>
							</div>
						</div>
					{/each}
				</div>
			</div>

			<!-- Navigation Buttons -->
			<div class="flex items-center justify-between">
				<button
					onclick={previousSection}
					disabled={isFirstSection}
					class="inline-flex items-center px-6 py-3 bg-white border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
				>
					<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
					</svg>
					Previous Section
				</button>

				{#if isLastSection}
					<button
						onclick={submitResponse}
						disabled={!canProceedToNext()}
						class="inline-flex items-center px-6 py-3 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
					>
						Submit Assessment
						<svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
					</button>
				{:else}
					<button
						onclick={nextSection}
						disabled={!canProceedToNext()}
						class="inline-flex items-center px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
					>
						Next Section
						<svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
						</svg>
					</button>
				{/if}
			</div>

			<!-- Required Fields Notice -->
			{#if !canProceedToNext()}
				<p class="mt-4 text-center text-sm text-red-600">
					Please answer all required questions (marked with *) before proceeding.
				</p>
			{/if}
		{/if}
	</div>
</div>
