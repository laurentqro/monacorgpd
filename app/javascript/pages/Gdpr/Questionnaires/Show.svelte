<script>
	import { router } from '@inertiajs/svelte';

	let { questionnaire } = $props();

	function editQuestionnaire() {
		router.visit(`/gdpr/questionnaires/${questionnaire.id}/edit`);
	}

	function publishQuestionnaire() {
		if (confirm('Are you sure you want to publish this questionnaire? Once published, users will be able to start assessments.')) {
			router.patch(`/gdpr/questionnaires/${questionnaire.id}/publish`);
		}
	}

	function archiveQuestionnaire() {
		if (confirm('Are you sure you want to archive this questionnaire?')) {
			router.patch(`/gdpr/questionnaires/${questionnaire.id}/archive`);
		}
	}

	function deleteQuestionnaire() {
		if (confirm('Are you sure you want to delete this questionnaire? This action cannot be undone.')) {
			router.delete(`/gdpr/questionnaires/${questionnaire.id}`);
		}
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
	<!-- Header -->
	<div class="mb-8">
		<div class="flex items-center justify-between mb-4">
			<div class="flex items-center space-x-4">
				<a
					href="/gdpr/questionnaires"
					class="text-gray-400 hover:text-gray-600"
				>
					<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
					</svg>
				</a>
				<div>
					<h1 class="text-3xl font-bold text-gray-900">{questionnaire.title}</h1>
					{#if questionnaire.description}
						<p class="mt-2 text-gray-600">{questionnaire.description}</p>
					{/if}
				</div>
			</div>

			<div class="flex items-center space-x-3">
				<span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium {getStatusBadgeClass(questionnaire.status)}">
					{questionnaire.status}
				</span>
			</div>
		</div>

		<!-- Actions -->
		<div class="flex items-center space-x-3">
			<button
				onclick={editQuestionnaire}
				class="inline-flex items-center px-4 py-2 bg-white border border-gray-300 text-gray-700 text-sm font-medium rounded-lg hover:bg-gray-50"
			>
				<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
				</svg>
				Edit
			</button>

			{#if questionnaire.status === 'draft'}
				<button
					onclick={publishQuestionnaire}
					class="inline-flex items-center px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700"
				>
					<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
					</svg>
					Publish
				</button>
			{/if}

			{#if questionnaire.status === 'published'}
				<button
					onclick={archiveQuestionnaire}
					class="inline-flex items-center px-4 py-2 bg-yellow-600 text-white text-sm font-medium rounded-lg hover:bg-yellow-700"
				>
					<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
					</svg>
					Archive
				</button>
			{/if}

			<button
				onclick={deleteQuestionnaire}
				class="inline-flex items-center px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-lg hover:bg-red-700"
			>
				<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
				</svg>
				Delete
			</button>
		</div>
	</div>

	<!-- Sections -->
	<div class="bg-white rounded-lg shadow-sm border border-gray-200">
		<div class="px-6 py-4 border-b border-gray-200">
			<div class="flex items-center justify-between">
				<h2 class="text-lg font-semibold text-gray-900">Sections</h2>
				<a
					href="/gdpr/questionnaires/{questionnaire.id}/sections/new"
					class="inline-flex items-center px-3 py-1.5 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
				>
					<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
					</svg>
					Add Section
				</a>
			</div>
		</div>

		{#if questionnaire.sections && questionnaire.sections.length > 0}
			<div class="divide-y divide-gray-200">
				{#each questionnaire.sections as section (section.id)}
					<div class="px-6 py-4 hover:bg-gray-50">
						<div class="flex items-start justify-between">
							<div class="flex-1">
								<h3 class="text-base font-medium text-gray-900">
									{section.title}
								</h3>
								{#if section.description}
									<p class="mt-1 text-sm text-gray-600">{section.description}</p>
								{/if}
								<div class="mt-2 flex items-center space-x-4 text-sm text-gray-500">
									<span class="flex items-center">
										<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
										</svg>
										{section.questions?.length || 0} questions
									</span>
								</div>
							</div>

							<div class="flex items-center space-x-2 ml-4">
								<a
									href="/gdpr/questionnaires/{questionnaire.id}/sections/{section.id}/questions"
									class="inline-flex items-center px-3 py-1.5 bg-gray-100 text-gray-700 text-sm font-medium rounded hover:bg-gray-200"
								>
									View Questions
								</a>
								<a
									href="/gdpr/questionnaires/{questionnaire.id}/sections/{section.id}/edit"
									class="inline-flex items-center px-3 py-1.5 bg-blue-100 text-blue-700 text-sm font-medium rounded hover:bg-blue-200"
								>
									Edit
								</a>
							</div>
						</div>

						<!-- Questions Preview -->
						{#if section.questions && section.questions.length > 0}
							<div class="mt-4 pl-4 border-l-2 border-gray-200">
								{#each section.questions.slice(0, 3) as question}
									<div class="mb-2 text-sm text-gray-600">
										<span class="font-medium">{question.question_text}</span>
										<span class="text-gray-400 ml-2">({question.question_type})</span>
									</div>
								{/each}
								{#if section.questions.length > 3}
									<div class="text-sm text-gray-400">
										+{section.questions.length - 3} more questions
									</div>
								{/if}
							</div>
						{/if}
					</div>
				{/each}
			</div>
		{:else}
			<div class="px-6 py-12 text-center">
				<svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
				</svg>
				<h3 class="mt-2 text-sm font-medium text-gray-900">No sections</h3>
				<p class="mt-1 text-sm text-gray-500">Get started by creating a new section.</p>
				<div class="mt-6">
					<a
						href="/gdpr/questionnaires/{questionnaire.id}/sections/new"
						class="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
					>
						<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
						</svg>
						Add Section
					</a>
				</div>
			</div>
		{/if}
	</div>

	<!-- Metadata -->
	{#if questionnaire.creator}
		<div class="mt-6 bg-gray-50 rounded-lg p-4">
			<dl class="grid grid-cols-2 gap-4 text-sm">
				<div>
					<dt class="font-medium text-gray-500">Created by</dt>
					<dd class="mt-1 text-gray-900">{questionnaire.creator.name || questionnaire.creator.email}</dd>
				</div>
				{#if questionnaire.category}
					<div>
						<dt class="font-medium text-gray-500">Category</dt>
						<dd class="mt-1 text-gray-900">{questionnaire.category}</dd>
					</div>
				{/if}
			</dl>
		</div>
	{/if}
</div>
