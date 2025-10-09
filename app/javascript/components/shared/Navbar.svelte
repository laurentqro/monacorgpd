<script>
	import { router } from '@inertiajs/svelte';

	let { currentUser, currentAccount } = $props();
	let showUserMenu = $state(false);
	let showMobileMenu = $state(false);

	function toggleUserMenu() {
		showUserMenu = !showUserMenu;
	}

	function toggleMobileMenu() {
		showMobileMenu = !showMobileMenu;
	}

	function closeMenus() {
		showUserMenu = false;
		showMobileMenu = false;
	}

	function signOut() {
		router.delete('/users/sign_out');
	}
</script>

<svelte:window onclick={closeMenus} />

<nav class="bg-white border-b border-gray-200">
	<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
		<div class="flex justify-between h-16">
			<!-- Logo and primary navigation -->
			<div class="flex">
				<div class="flex-shrink-0 flex items-center">
					<a href="/gdpr/questionnaires" class="text-xl font-bold text-gray-900">
						MonacoRGPD
					</a>
				</div>
				<div class="hidden sm:ml-6 sm:flex sm:space-x-8">
					<a
						href="/gdpr/questionnaires"
						class="inline-flex items-center px-1 pt-1 border-b-2 border-blue-500 text-sm font-medium text-gray-900"
					>
						Questionnaires
					</a>
				</div>
			</div>

			<!-- Right side - User menu -->
			<div class="hidden sm:ml-6 sm:flex sm:items-center">
				{#if currentUser}
					<!-- Account info -->
					{#if currentAccount}
						<div class="mr-4 text-sm text-gray-600">
							{currentAccount.name}
						</div>
					{/if}

					<!-- User menu dropdown -->
					<div class="ml-3 relative">
						<button
							type="button"
							onclick={(e) => {
								e.stopPropagation();
								toggleUserMenu();
							}}
							class="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
						>
							<span class="sr-only">Open user menu</span>
							{#if currentUser.avatar_url}
								<img class="h-8 w-8 rounded-full object-cover" src={currentUser.avatar_url} alt={currentUser.name || currentUser.email} />
							{:else}
								<div class="h-8 w-8 rounded-full bg-blue-600 flex items-center justify-center text-white text-sm font-medium">
									{(currentUser.name || currentUser.email).charAt(0).toUpperCase()}
								</div>
							{/if}
						</button>

						{#if showUserMenu}
							<div
								onclick={(e) => e.stopPropagation()}
								class="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 focus:outline-none z-50"
							>
								<div class="px-4 py-2 text-xs text-gray-500 border-b border-gray-100">
									{currentUser.email}
								</div>
								<a
									href="/account/edit"
									class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
								>
									Profile
								</a>
								<a
									href="/account/password/edit"
									class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
								>
									Password
								</a>
								<a
									href="/accounts"
									class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
								>
									Accounts
								</a>
								<button
									onclick={signOut}
									class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 border-t border-gray-100"
								>
									Sign out
								</button>
							</div>
						{/if}
					</div>
				{:else}
					<a
						href="/users/sign_in"
						class="text-sm font-medium text-gray-700 hover:text-gray-900 mr-4"
					>
						Sign in
					</a>
					<a
						href="/users/sign_up"
						class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
					>
						Sign up
					</a>
				{/if}
			</div>

			<!-- Mobile menu button -->
			<div class="flex items-center sm:hidden">
				<button
					type="button"
					onclick={(e) => {
						e.stopPropagation();
						toggleMobileMenu();
					}}
					class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500"
				>
					<span class="sr-only">Open main menu</span>
					<svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
					</svg>
				</button>
			</div>
		</div>
	</div>

	<!-- Mobile menu -->
	{#if showMobileMenu}
		<div class="sm:hidden" onclick={(e) => e.stopPropagation()}>
			<div class="pt-2 pb-3 space-y-1">
				<a
					href="/gdpr/questionnaires"
					class="block pl-3 pr-4 py-2 border-l-4 border-blue-500 text-base font-medium text-blue-700 bg-blue-50"
				>
					Questionnaires
				</a>
			</div>
			{#if currentUser}
				<div class="pt-4 pb-3 border-t border-gray-200">
					<div class="flex items-center px-4">
						{#if currentUser.avatar_url}
							<img class="h-10 w-10 rounded-full object-cover" src={currentUser.avatar_url} alt={currentUser.name || currentUser.email} />
						{:else}
							<div class="h-10 w-10 rounded-full bg-blue-600 flex items-center justify-center text-white font-medium">
								{(currentUser.name || currentUser.email).charAt(0).toUpperCase()}
							</div>
						{/if}
						<div class="ml-3">
							<div class="text-base font-medium text-gray-800">{currentUser.name || 'User'}</div>
							<div class="text-sm font-medium text-gray-500">{currentUser.email}</div>
						</div>
					</div>
					<div class="mt-3 space-y-1">
						<a
							href="/account/edit"
							class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100"
						>
							Profile
						</a>
						<a
							href="/account/password/edit"
							class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100"
						>
							Password
						</a>
						<a
							href="/accounts"
							class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100"
						>
							Accounts
						</a>
						<button
							onclick={signOut}
							class="block w-full text-left px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100"
						>
							Sign out
						</button>
					</div>
				</div>
			{/if}
		</div>
	{/if}
</nav>
