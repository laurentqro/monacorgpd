class Account < ApplicationRecord
  has_prefix_id :acct

  include Billing
  include Domains
  include Transfer
  include Types
  include GdprQuestionnaires  # Our GDPR extension
end
