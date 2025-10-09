# Separation Strategy: GDPR App vs Jumpstart Pro

## Philosophy

Our GDPR questionnaire application is built **on top of** Jumpstart Pro, not **mixed with** it. This ensures:
- ✅ Clean Jumpstart Pro upgrades
- ✅ Clear code ownership
- ✅ Modular architecture
- ✅ Easy maintenance

## Directory Structure

### Our Code (GDPR Application)

```
app/
├── controllers/
│   └── gdpr/  ← All our controllers namespaced
│       ├── base_controller.rb
│       ├── questionnaires_controller.rb
│       ├── sections_controller.rb
│       ├── questions_controller.rb
│       └── responses_controller.rb
│
├── models/
│   ├── questionnaire.rb  ← Our models (root level)
│   ├── section.rb
│   ├── question.rb
│   ├── answer_choice.rb
│   ├── logic_rule.rb
│   ├── response.rb
│   ├── answer.rb
│   ├── audit_session.rb
│   ├── compliance_area.rb
│   ├── compliance_area_score.rb
│   └── concerns/
│       └── account/
│           └── gdpr_questionnaires.rb  ← Extensions only
│
├── javascript/
│   └── pages/
│       └── Gdpr/  ← Our Svelte components (to be created)
│           ├── Questionnaires/
│           ├── Sections/
│           ├── Questions/
│           └── Responses/
│
config/
├── routes.rb  ← Jumpstart routes + "draw :gdpr"
└── routes/
    ├── gdpr.rb  ← Our routes
    ├── accounts.rb  ← Jumpstart
    ├── billing.rb  ← Jumpstart
    └── users.rb  ← Jumpstart

docs/
├── architecture/  ← Our documentation
├── implementation/
├── reference/
└── schemas/
```

### Jumpstart Pro Code (Unchanged)

```
app/
├── controllers/
│   ├── accounts_controller.rb  ← Jumpstart
│   ├── billing_controller.rb  ← Jumpstart
│   └── dashboard_controller.rb  ← Jumpstart
│
├── models/
│   ├── account.rb  ← Extended via concern
│   ├── user.rb  ← May extend later
│   └── concerns/
│       ├── account/
│       │   ├── billing.rb  ← Jumpstart
│       │   ├── domains.rb  ← Jumpstart
│       │   └── gdpr_questionnaires.rb  ← Ours!
│       └── user/
│           └── respondent.rb  ← Ours (if needed)
```

## Extension Points

### 1. Controllers (Namespaced)

**Pattern:** All our controllers under `Gdpr::` namespace

```ruby
# app/controllers/gdpr/base_controller.rb
module Gdpr
  class BaseController < ApplicationController
    # Inherits from Jumpstart's ApplicationController
    # Adds GDPR-specific logic
  end
end
```

**Benefits:**
- No conflicts with Jumpstart controllers
- Clear ownership in `app/controllers/gdpr/`
- Easy to grep: `grep -r "module Gdpr"`

### 2. Models (Concerns for Extensions)

**Pattern:** New models at root, extend Jumpstart models via concerns

```ruby
# app/models/concerns/account/gdpr_questionnaires.rb
module Account::GdprQuestionnaires
  extend ActiveSupport::Concern

  included do
    has_many :questionnaires
  end
end

# app/models/account.rb
class Account < ApplicationRecord
  include Billing  # Jumpstart
  include Domains  # Jumpstart
  include GdprQuestionnaires  # Ours
end
```

**Benefits:**
- Follows Jumpstart's concern pattern
- Non-invasive (just adds associations)
- Easy to see what's ours: `Account::GdprQuestionnaires`

### 3. Routes (Separate File)

**Pattern:** All GDPR routes in `config/routes/gdpr.rb`

```ruby
# config/routes/gdpr.rb
Rails.application.routes.draw do
  namespace :gdpr do
    resources :questionnaires
  end
end

# config/routes.rb
Rails.application.routes.draw do
  draw :gdpr  # Single line to include our routes
  # ... Jumpstart routes
end
```

**Benefits:**
- All GDPR routes in one file
- Clear URL namespace: `/gdpr/*`
- Single line in main routes.rb

### 4. Views (Namespaced Directory)

**Pattern:** Svelte components under `Gdpr/` directory (to be created)

```
app/javascript/pages/
├── Gdpr/  ← Our components
│   ├── Questionnaires/
│   │   ├── Index.svelte
│   │   ├── Show.svelte
│   │   └── Form.svelte
│   └── Responses/
│       └── Take.svelte
└── Dashboard.svelte  ← Jumpstart
```

**Benefits:**
- Clear visual separation
- No Inertia page name conflicts
- Easy to find: `pages/Gdpr/`

## Upgrade Path

### Upgrading Jumpstart Pro

```bash
# 1. Upgrade Jumpstart
rails app:template LOCATION=https://jumpstart.pro/template

# 2. Review changes
git diff

# 3. Resolve conflicts (if any)
# Our code is separate, so conflicts should be minimal

# 4. Test GDPR functionality
bin/rails test:models
bin/rails test:controllers
```

**Conflicts should be minimal because:**
- ✅ Controllers are namespaced (`Gdpr::`)
- ✅ Models are separate or use concerns
- ✅ Routes are in separate file
- ✅ Views are in separate directory

## What We Don't Touch

❌ **Never modify these directly:**
- `app/controllers/accounts_controller.rb`
- `app/controllers/billing_controller.rb`
- `app/models/account.rb` (except adding `include GdprQuestionnaires`)
- `app/models/user.rb` (except adding concerns)
- `config/routes/accounts.rb`
- `config/routes/billing.rb`

✅ **Only extend via:**
- Concerns (e.g., `Account::GdprQuestionnaires`)
- Inheritance (e.g., `Gdpr::BaseController < ApplicationController`)
- Configuration (e.g., adding `draw :gdpr`)

## Testing Separation

```ruby
# Test that GDPR code is separate
describe "GDPR code separation" do
  it "all GDPR controllers are namespaced" do
    gdpr_controllers = Dir["app/controllers/gdpr/**/*.rb"]
    assert gdpr_controllers.all? { |f| File.read(f).include?("module Gdpr") }
  end

  it "all GDPR routes are in separate file" do
    routes_content = File.read("config/routes/gdpr.rb")
    assert routes_content.include?("namespace :gdpr")
  end
end
```

## Benefits Achieved

1. **Maintainability**
   - Clear code ownership
   - Easy to locate GDPR code
   - Jumpstart updates won't break our code

2. **Modularity**
   - Could extract to Rails engine later
   - Could ship as separate repo
   - Easy to disable/remove

3. **Team Clarity**
   - New devs immediately see separation
   - No confusion about what's ours vs. Jumpstart
   - Clear review boundaries

4. **Testing**
   - Test our code independently
   - Mock Jumpstart dependencies
   - Faster test suite

## Related Documentation

- [Database Design](database-design.md) - Multi-tenant architecture
- [Implementation Plan](../implementation/implementation-plan.md) - Development phases
- [CLAUDE.md](../../CLAUDE.md) - Rails conventions
