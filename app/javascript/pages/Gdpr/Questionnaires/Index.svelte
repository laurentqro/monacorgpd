<script>
	import { router } from '@inertiajs/svelte';

	let { questionnaires, statuses } = $props();

	function startQuestionnaire(questionnaireId) {
		router.post(`/gdpr/questionnaires/${questionnaireId}/responses`);
	}

	function viewQuestionnaire(questionnaireId) {
		router.visit(`/gdpr/questionnaires/${questionnaireId}`);
	}

	function getStatusBadgeClass(status) {
		const classes = {
			draft: 'bg-gray-100 text-gray-800',
			published: 'bg-green-100 text-green-800',
			archived: 'bg-yellow-100 text-yellow-800'
		};
		return classes[status] || 'bg-gray-100 text-gray-800';
	}
</script>

<div class="max-w-7xl mx-auto px-4 py-8">
	<div class="flex items-center justify-between mb-8">
		<div>
			<h1 class="text-3xl font-bold text-gray-900">Monaco RGPD Questionnaires</h1>
			<p class="mt-2 text-sm text-gray-600">
				Compliance questionnaires for Monaco Law 1.565
			</p>
		</div>
		<a
			href="/gdpr/questionnaires/new"
			class="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
		>
			<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
			</svg>
			New Questionnaire
		</a>
	</div>

	{#if questionnaires && questionnaires.length > 0}
		<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
			{#each questionnaires as questionnaire (questionnaire.id)}
				<div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow">
					<div class="p-6">
						<div class="flex items-start justify-between mb-4">
							<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {getStatusBadgeClass(questionnaire.status)}">
								{questionnaire.status}
							</span>
							{#if questionnaire.category}
								<span class="text-xs text-gray-500 uppercase tracking-wide">
									{questionnaire.category}
								</span>
							{/if}
						</div>

						<h3 class="text-lg font-semibold text-gray-900 mb-2">
							{questionnaire.title}
						</h3>

						{#if questionnaire.description}
							<p class="text-sm text-gray-600 line-clamp-2 mb-4">
								{questionnaire.description}
							</p>
						{/if}

						<div class="flex items-center justify-between text-sm text-gray-500 mb-4 pt-4 border-t border-gray-100">
							<div class="flex items-center space-x-4">
								<span class="flex items-center">
									<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
									</svg>
									{questionnaire.sections?.length || 0} sections
								</span>
								<span class="flex items-center">
									<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
									</svg>
									{questionnaire.questions_count || 0} questions
								</span>
							</div>
						</div>

						<div class="flex gap-2">
							<button
								onclick={() => viewQuestionnaire(questionnaire.id)}
								class="flex-1 px-4 py-2 bg-gray-100 text-gray-700 text-sm font-medium rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
							>
								View Details
							</button>
							{#if questionnaire.status === 'published'}
								<button
									onclick={() => startQuestionnaire(questionnaire.id)}
									class="flex-1 px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
								>
									Start Assessment
								</button>
							{/if}
						</div>
					</div>
				</div>
			{/each}
		</div>
	{:else}
		<div class="text-center py-12">
			<svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
			</svg>
			<h3 class="mt-2 text-sm font-medium text-gray-900">No questionnaires</h3>
			<p class="mt-1 text-sm text-gray-500">Get started by creating a new RGPD questionnaire.</p>
			<div class="mt-6">
				<a
					href="/gdpr/questionnaires/new"
					class="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
				>
					<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
					</svg>
					New Questionnaire
				</a>
			</div>
		</div>
	{/if}
</div>

<style>
	.line-clamp-2 {
		display: -webkit-box;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
	}
</style>
