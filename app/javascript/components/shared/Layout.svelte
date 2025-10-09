<script>
	import Navbar from './Navbar.svelte';
	import { page } from '@inertiajs/svelte';

	let { children } = $props();

	let currentUser = $derived($page.props.current_user);
	let currentAccount = $derived($page.props.current_account);
</script>

<div class="min-h-screen bg-gray-50">
	<Navbar {currentUser} {currentAccount} />

	<main>
		{@render children()}
	</main>

	<footer class="bg-white border-t border-gray-200 mt-auto">
		<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
			<p class="text-center text-sm text-gray-500">
				© {new Date().getFullYear()} MonacoRGPD. All rights reserved.
			</p>
		</div>
	</footer>
</div>
