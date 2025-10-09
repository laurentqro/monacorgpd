<script>
	let { question, value = $bindable(), onchange } = $props();

	// Handle value changes and call parent onchange
	function handleChange(newValue) {
		value = newValue;
		if (onchange) {
			onchange(newValue);
		}
	}

	// Specific handlers for different input types
	function handleRadioChange(event) {
		const choiceId = parseInt(event.target.value);
		handleChange({ choice_id: choiceId });
	}

	function handleCheckboxChange(event) {
		const choiceId = parseInt(event.target.value);
		const currentChoices = value?.choice_ids || [];

		const newChoices = event.target.checked
			? [...currentChoices, choiceId]
			: currentChoices.filter(id => id !== choiceId);

		handleChange({ choice_ids: newChoices });
	}

	function handleTextChange(event) {
		handleChange({ text: event.target.value });
	}

	function handleYesNoChange(event) {
		handleChange({ value: event.target.value });
	}

	function handleRatingChange(event) {
		handleChange({ rating: parseInt(event.target.value) });
	}

	// Helper functions
	function isChoiceSelected(choiceId) {
		return value?.choice_id === choiceId;
	}

	function isChoiceChecked(choiceId) {
		return value?.choice_ids?.includes(choiceId) || false;
	}

	function getRatingValue() {
		return value?.rating || (question.settings?.min || 1);
	}

	function getTextValue() {
		return value?.text || '';
	}

	function getYesNoValue() {
		return value?.value || '';
	}
</script>

{#if question.question_type === 'single_choice'}
	<!-- Single Choice (Radio Buttons) -->
	<div class="space-y-3">
		{#each question.answer_choices as choice (choice.id)}
			<label class="flex items-center p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors {isChoiceSelected(choice.id) ? 'border-blue-500 bg-blue-50' : ''}">
				<input
					type="radio"
					name="question-{question.id}"
					value={choice.id}
					checked={isChoiceSelected(choice.id)}
					onchange={handleRadioChange}
					class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500"
				/>
				<span class="ml-3 text-gray-900">{choice.choice_text}</span>
			</label>
		{/each}
	</div>

{:else if question.question_type === 'multiple_choice'}
	<!-- Multiple Choice (Checkboxes) -->
	<div class="space-y-3">
		{#each question.answer_choices as choice (choice.id)}
			<label class="flex items-center p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors {isChoiceChecked(choice.id) ? 'border-blue-500 bg-blue-50' : ''}">
				<input
					type="checkbox"
					value={choice.id}
					checked={isChoiceChecked(choice.id)}
					onchange={handleCheckboxChange}
					class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
				/>
				<span class="ml-3 text-gray-900">{choice.choice_text}</span>
			</label>
		{/each}
	</div>

{:else if question.question_type === 'text_short'}
	<!-- Short Text Input -->
	<input
		type="text"
		value={getTextValue()}
		oninput={handleTextChange}
		placeholder="Enter your answer..."
		class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
	/>

{:else if question.question_type === 'text_long'}
	<!-- Long Text Input (Textarea) -->
	<textarea
		value={getTextValue()}
		oninput={handleTextChange}
		placeholder="Enter your answer..."
		rows="6"
		class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-y"
	></textarea>

{:else if question.question_type === 'yes_no'}
	<!-- Yes/No Toggle -->
	<div class="flex space-x-4">
		<label class="flex items-center p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors flex-1 {getYesNoValue() === 'yes' ? 'border-green-500 bg-green-50' : 'border-gray-200'}">
			<input
				type="radio"
				name="question-{question.id}"
				value="yes"
				checked={getYesNoValue() === 'yes'}
				onchange={handleYesNoChange}
				class="w-4 h-4 text-green-600 border-gray-300 focus:ring-green-500"
			/>
			<span class="ml-3 font-medium {getYesNoValue() === 'yes' ? 'text-green-900' : 'text-gray-700'}">
				Yes
			</span>
		</label>
		<label class="flex items-center p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors flex-1 {getYesNoValue() === 'no' ? 'border-red-500 bg-red-50' : 'border-gray-200'}">
			<input
				type="radio"
				name="question-{question.id}"
				value="no"
				checked={getYesNoValue() === 'no'}
				onchange={handleYesNoChange}
				class="w-4 h-4 text-red-600 border-gray-300 focus:ring-red-500"
			/>
			<span class="ml-3 font-medium {getYesNoValue() === 'no' ? 'text-red-900' : 'text-gray-700'}">
				No
			</span>
		</label>
	</div>

{:else if question.question_type === 'rating_scale'}
	<!-- Rating Scale -->
	<div class="space-y-4">
		<div class="flex items-center justify-between">
			<span class="text-sm text-gray-500">
				{question.settings?.min || 1}
			</span>
			<input
				type="range"
				min={question.settings?.min || 1}
				max={question.settings?.max || 10}
				value={getRatingValue()}
				oninput={handleRatingChange}
				class="flex-1 mx-4 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-blue-600"
			/>
			<span class="text-sm text-gray-500">
				{question.settings?.max || 10}
			</span>
		</div>
		<div class="text-center">
			<span class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-blue-600 text-white text-xl font-bold">
				{getRatingValue()}
			</span>
		</div>
	</div>

{:else}
	<!-- Fallback for unknown question types -->
	<div class="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
		<p class="text-sm text-yellow-800">
			Unknown question type: {question.question_type}
		</p>
	</div>
{/if}
