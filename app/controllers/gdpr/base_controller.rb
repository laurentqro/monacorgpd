module Gdpr
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_account

    private

    def set_account
      # Ensure user has access to current account
      unless current_user.accounts.include?(current_account)
        redirect_to root_path, alert: "You don't have access to this account"
      end
    end

    # Scope all queries to current account for multi-tenancy
    def scoped_questionnaires
      current_account.questionnaires
    end

    def scoped_responses
      current_account.responses
    end

    def scoped_audit_sessions
      current_account.audit_sessions
    end
  end
end
