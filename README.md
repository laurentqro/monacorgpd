# 🎉 Jumpstart Pro Rails

Welcome! To get started, clone the repository and push it to a new repository.

## Requirements

You'll need the following installed to run the template successfully:

* Ruby 3.2+
* PostgreSQL 12+ (can be switched to SQLite or MySQL)
* Libvips or Imagemagick
* Node.js 18+ and npm (for Inertia.js with Svelte and Vite)

Optionally, the [Stripe CLI](https://docs.stripe.com/stripe-cli) to sync webhooks in development.

## Create Your Repository

Create a [new Git](https://github.com/new) repository for your project. Then you can clone Jumpstart Pro and push it to your new repository.

```bash
git clone https://github.com/jumpstart-pro/jumpstart-pro-rails.git myapp
cd myapp
git remote rename origin jumpstart-pro
git remote add origin https://github.com/your-account/your-repo.git # Replace with your new Git repository url
git push -u origin main
```

## Initial Setup

First, edit `config/database.yml` and change the database credentials for your server.

Run `bin/setup` to install Ruby and JavaScript dependencies and setup your database.

```bash
bin/setup
```

This will install both Ruby gems and npm packages (including Inertia.js, Svelte, and Vite dependencies).

## Running Jumpstart Pro Rails

To run your application, you'll use the `bin/dev` command:

```bash
bin/dev
```

This starts up Overmind running the processes defined in `Procfile.dev`. We've configured this to run the Rails server, Vite dev server (for Inertia.js + Svelte), and CSS bundling out of the box. You can add background workers like Sidekiq, the Stripe CLI, etc to have them run at the same time.

#### Running on Windows

See the [Installation docs](https://jumpstartrails.com/docs/installation#windows)

#### Running with Docker or Docker Compose

See the [Installation docs](https://jumpstartrails.com/docs/installation#docker)

## Merging Updates

To merge changes from Jumpstart Pro, you will merge from the `jumpstart-pro` remote.

```bash
git fetch jumpstart-pro
git merge jumpstart-pro/main
```

## Inertia.js + Svelte

This application includes Inertia.js with Svelte 5 for building modern single-page application experiences.

### Tech Stack
- **Inertia.js**: The modern monolith - build SPAs without building an API
- **Svelte 5**: Reactive UI framework with powerful runes for state management
- **Vite**: Fast build tool and dev server via vite-plugin-ruby
- **TailwindCSS v4**: Utility-first CSS via @tailwindcss/vite plugin

### Creating Inertia Pages
1. Create a `.svelte` file in `app/javascript/pages/`
2. Use Svelte 5 runes (`$state`, `$derived`, `$effect`) for reactive state management
3. Render from a controller using `render inertia: 'PageName', props: { key: value }`
4. See `app/controllers/inertia_example_controller.rb` and `app/javascript/pages/InertiaExample.svelte` for examples

### Configuration
- **Inertia config**: `config/initializers/inertia_rails.rb`
- **Vite config**: `vite.config.ts`
- **Svelte config**: `svelte.config.js`
- **Entry point**: `app/javascript/entrypoints/inertia.js`

## Contributing

If you have an improvement you'd like to share, create a fork of the repository and send us a pull request.
