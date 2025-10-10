# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**MonacoRGPD** is a multi-tenant SaaS application for Monaco data protection compliance built on Jumpstart Pro Rails. It helps organizations comply with **Monaco's Law No. 1.565** (December 3, 2024) on the protection of personal data, overseen by the **APDP** (Autorité de Protection des Données Personnelles).

### Monaco Data Protection Context

- **Law 1.565**: Monaco's data protection law (December 3, 2024)
- **APDP**: Monaco's data protection authority (formerly CCIN)
- **Convention 108+**: International data protection treaty (Monaco ratified March 6, 2025)
- **RGPD Alignment**: Monaco's law aligns with EU GDPR principles while being Monaco-specific
- **Documentation**: Full law text in `docs/loi-1565/` (Chapters I-X), APDP guidance in `docs/apdp/`

### Application Purpose

Provide Monaco-based organizations with:
- GDPR-aligned compliance questionnaires
- Data protection impact assessments (DPIA)
- Treatment activities register (required for 50+ employees)
- Audit sessions with compliance scoring
- Support for APDP reporting requirements (72-hour breach notification)

### Jumpstart Pro Foundation

Built on Jumpstart Pro Rails 8, which provides subscription billing, team management, authentication, and modern Rails patterns for SaaS applications.

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
- **Vite** for JavaScript bundling and development (via vite-plugin-ruby)
- **PostgreSQL** (primary), **SolidQueue** (jobs), **SolidCache** (cache), **SolidCable** (websockets)
- **Import Maps** for JavaScript (for traditional Rails views, no Node.js dependency)
- **TailwindCSS v4** via @tailwindcss/vite plugin and tailwindcss-rails gem
- **Pagy** (~43.0) for pagination (Jumpstart Pro default)
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
- `app/helpers/` - View helpers (organized by namespace)
- `app/views/` - ERB templates (organized by namespace)
- `lib/jumpstart/` - Core Jumpstart engine and configuration
- `config/routes/` - Modular route definitions
- `app/components/` - View components for reusable UI
- `app/javascript/controllers/` - Stimulus controllers
- `app/javascript/entrypoints/` - Vite entrypoints

## Pagination with Pagy

This application uses **Pagy** for pagination (Jumpstart Pro's default pagination gem).

**Official Documentation**: https://ddnexus.github.io/pagy/

### Controller Usage
```ruby
def index
  scope = Model.where(account: current_account).order(created_at: :desc)
  @pagy, @records = pagy(scope)
end
```

### View Usage
```erb
<%# Display pagination only when needed %>
<% if @pagy.count > @pagy.limit %>
  <div class="mt-4">
    <%== pagy_nav(@pagy) %>
  </div>
<% end %>
```

### Key Methods
- `pagy(scope, items: 20)` - Returns `[@pagy, @records]` tuple
- `pagy_nav(@pagy)` - Generates pagination links (HTML safe)
- `@pagy.count` - Total number of records
- `@pagy.limit` - Items per page
- `@pagy.page` - Current page number
- `@pagy.pages` - Total number of pages (if needed)

## AI-Assisted Development

This project uses **[claude-on-rails](https://github.com/obie/claude-on-rails)** to provide additional Rails-specific context and best practices to Claude Code.

- **Context file**: `.claude-on-rails/context.md` (automatically referenced by Claude Code)
- **Purpose**: Provides Rails conventions, patterns, and best practices specific to modern Rails development
- **Installation**: Added via `gem 'claude-on-rails'` in Gemfile

## Development Notes

- **Current account** available via `current_account` helper in controllers/views
- **Account switching** via `switch_account(account)` in tests
- **Billing features** conditionally loaded based on `Jumpstart.config.payments_enabled?`
- **Background jobs** configurable between SolidQueue and Sidekiq
- **Multi-database** setup with separate databases for cache, jobs, and cable
- **Pagination**: Use Pagy for all paginated views; see "Pagination with Pagy" section above

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
/file:.claude-on-rails/context.md
