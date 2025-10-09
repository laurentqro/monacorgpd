import { createInertiaApp } from '@inertiajs/svelte'
import { mount } from 'svelte';
import Layout from '../components/shared/Layout.svelte';

createInertiaApp({
  // Disable progress bar
  //
  // see https://inertia-rails.dev/guide/progress-indicators
  // progress: false,

  resolve: (name) => {
    const pages = import.meta.glob('../pages/**/*.svelte', {
      eager: true,
    })
    const page = pages[`../pages/${name}.svelte`]
    if (!page) {
      console.error(`Missing Inertia page component: '${name}.svelte'`)
    }

    // Use Layout component as default layout for all pages
    // Pages can override by defining their own layout property
    // see https://inertia-rails.dev/guide/pages#default-layouts
    return { default: page.default, layout: page.layout || Layout }
  },

  setup({ el, App, props }) {
    if (el) {
      mount(App, { target: el, props })
    } else {
      console.error(
        'Missing root element.\n\n' +
          'If you see this error, it probably means you load Inertia.js on non-Inertia pages.\n' +
          'Consider moving <%= vite_javascript_tag "inertia" %> to the Inertia-specific layout instead.',
      )
    }
  },
})
