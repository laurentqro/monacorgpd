# frozen_string_literal: true

InertiaRails.configure do |config|
  config.version = ViteRuby.digest
  config.encrypt_history = true
  config.always_include_errors_hash = true

  # Share current_user and current_account data with all Inertia pages
  config.shared_data[:current_user] = lambda do |context|
    controller = context[:controller]
    user = controller.current_user

    if user
      {
        id: user.id,
        name: user.name,
        email: user.email,
        avatar_url: controller.avatar_url_for(user)
      }
    end
  end

  config.shared_data[:current_account] = lambda do |context|
    controller = context[:controller]
    account = controller.current_account

    if account
      {
        id: account.id,
        name: account.name,
        personal: account.personal?
      }
    end
  end
end
