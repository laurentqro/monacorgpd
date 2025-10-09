# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Jumpstart Pro Rails is a commercial multi-tenant SaaS starter application built with Rails 8. It provides subscription billing, team management, authentication, and modern Rails patterns for building subscription-based web applications.

## Development Commands

```bash
# Initial setup
bin/setup                    # Install dependencies and setup database

# Development server
bin/dev                      # Start development server with Overmind (includes Rails server, asset watching)
bin/rails server            # Standard Rails server only

# Database
bin/rails db:prepare         # Setup database (creates, migrates, seeds)
bin/rails db:migrate         # Run migrations
bin/rails db:seed           # Seed database

# Testing
bin/rails test              # Run test suite (Minitest)
bin/rails test:system       # Run system tests (Capybara + Selenium)

# Code quality
bin/rubocop                 # Run RuboCop linter (configured in .rubocop.yml)
bin/rubocop -a              # Auto-fix RuboCop issues

# Background jobs
bin/jobs                    # Start SolidQueue worker (if using SolidQueue)
bundle exec sidekiq         # Start Sidekiq worker (if using Sidekiq)
```

## Architecture

### Multi-tenancy System
- **Account-based tenancy**: Users belong to Accounts (personal or team)
- **AccountUser model**: Join table managing user-account relationships with roles
- **Current account switching**: Users can switch between accounts via `switch_account(account)`
- **Authorization**: Pundit policies scope data by current account

### Modular Models
Models use Ruby modules for organization:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  include Accounts, Agreements, Authenticatable, Mentions, Notifiable, Searchable, Theme
end

# app/models/account.rb  
class Account < ApplicationRecord
  include Billing, Domains, Transfer, Types
end
```

### Jumpstart Configuration System
- **Dynamic configuration**: `config/jumpstart.yml` controls enabled features
- **Runtime gem loading**: `Gemfile.jumpstart` loads gems based on configuration
- **Feature toggles**: Payment processors, integrations, background jobs, etc.
- Access via `Jumpstart.config.payment_processors`, `Jumpstart.config.stripe?`, etc.

### Payment Architecture
- **Pay gem (~11.0)**: Unified interface for multiple payment processors
- **Processor-agnostic**: Stripe, Paddle, Braintree, PayPal, Lemon Squeezy support
- **Per-seat billing**: Team accounts with usage-based pricing
- **Subscription management**: In `app/models/account/billing.rb`
- **Email delivery**: Mailgun, Mailpace, Postmark, and Resend use API gems instead of SMTP
- **API client errors**: Raise `UnprocessableContent` for 422 responses (rfc9110)

## Technology Stack

- **Rails 8** with Hotwire (Turbo + Stimulus) and Hotwire Native
- **Inertia.js** with **Svelte 5** for building modern SPAs (optional, alongside Hotwire)
- **Vite** for JavaScript bundling and development (for Inertia pages via vite-plugin-ruby)
- **PostgreSQL** (primary), **SolidQueue** (jobs), **SolidCache** (cache), **SolidCable** (websockets)
- **Import Maps** for JavaScript (for traditional Rails views, no Node.js dependency)
- **TailwindCSS v4** via @tailwindcss/vite plugin and tailwindcss-rails gem
- **Devise** for authentication with custom extensions
- **Pundit** for authorization
- **Minitest** for testing with parallel execution

## Testing

- **Minitest** with fixtures in `test/fixtures/`
- **System tests** use Capybara with Selenium WebDriver
- **Test parallelization** enabled via `parallelize(workers: :number_of_processors)`
- **WebMock** configured to disable external HTTP requests
- **Test database** reset between runs

## Routes Organization

Routes are modularized in `config/routes/`:
- `accounts.rb` - Account management, switching, invitations
- `billing.rb` - Subscription, payment, receipt routes
- `users.rb` - User profile, settings, authentication
- `api.rb` - API v1 endpoints with JWT authentication

## Key Directories

- `app/controllers/accounts/` - Account-scoped controllers
- `app/models/concerns/` - Shared model modules
- `app/policies/` - Pundit authorization policies
- `lib/jumpstart/` - Core Jumpstart engine and configuration
- `config/routes/` - Modular route definitions
- `app/components/` - View components for reusable UI
- `app/javascript/pages/` - Inertia.js Svelte page components
- `app/javascript/entrypoints/` - Vite entrypoints (including inertia.js)

## Inertia.js + Svelte Integration

This application includes Inertia.js with Svelte 5 for building modern single-page application (SPA) experiences alongside traditional Hotwire views.

**Official Documentation for LLMs:**
- Inertia Rails: https://inertia-rails.dev/llms-full.txt
- Svelte 5: https://svelte.dev/docs/svelte/llms.txt

### Configuration
- **Inertia Rails gem**: Installed and configured in `config/initializers/inertia_rails.rb`
- **Vite**: Configured in `vite.config.ts` with Svelte and Tailwind plugins
- **Entry point**: `app/javascript/entrypoints/inertia.js` handles Inertia setup and page resolution
- **Svelte config**: `svelte.config.js` with vitePreprocess

### NPM Dependencies
```json
{
  "@inertiajs/svelte": "^2.2.7",
  "@sveltejs/vite-plugin-svelte": "^6.2.1",
  "svelte": "^5.39.11",
  "vite": "^7.1.9",
  "vite-plugin-ruby": "^5.1.1",
  "@tailwindcss/vite": "^4.1.14"
}
```

### Usage
- **Create Inertia pages**: Add `.svelte` files in `app/javascript/pages/`
- **Render from controllers**: Use `render inertia: 'ComponentName', props: { data: value }`
- **Svelte 5 features**: Use runes (`$state`, `$derived`, `$effect`) for reactivity
- **Example controller**: See `app/controllers/inertia_example_controller.rb`
- **Example page**: See `app/javascript/pages/InertiaExample.svelte`

### Key Features
- Encrypted history enabled
- Asset versioning via ViteRuby digest
- Automatic page resolution from `app/javascript/pages/` directory
- Shared props support for flash messages, errors, etc.

## Development Notes

- **Current account** available via `current_account` helper in controllers/views
- **Account switching** via `switch_account(account)` in tests
- **Billing features** conditionally loaded based on `Jumpstart.config.payments_enabled?`
- **Background jobs** configurable between SolidQueue and Sidekiq
- **Multi-database** setup with separate databases for cache, jobs, and cable
- **Inertia pages**: Use Svelte 5 with runes for reactivity; pages auto-loaded from `app/javascript/pages/`

## Rails Conventions & Best Practices

### Database Migrations
- **One migration per table**: Create separate migration files for each table, not monolithic migrations
- **No database triggers**: Avoid database-level triggers (e.g., `update_updated_at_column()`)
- **Use Rails conventions**: Rely on ActiveRecord callbacks and `t.timestamps` instead of custom DB logic
- **Standard Rails DSL**: Use Rails migration methods rather than raw SQL when possible

### Enums
- **Use integer-based enums**: Store enums as integers (0, 1, 2...) not PostgreSQL ENUM types
- **Define in models**: Use ActiveRecord's `enum` method with explicit mappings in models
- **Benefits**: Database-agnostic, easy to modify, automatic scopes/methods, better performance
- **Example**:
  ```ruby
  # Migration
  t.integer :status, null: false, default: 0

  # Model
  enum status: { draft: 0, published: 1, archived: 2 }
  ```
- **Reference**: See `docs/enum-mappings.md` for all enum definitions

### Multi-tenancy
- **Account scoping**: All root tables must have `account_id` foreign key
- **Composite indexes**: Add `account_id` to frequently queried indexes
- **Pundit policies**: Scope all queries by `current_account`