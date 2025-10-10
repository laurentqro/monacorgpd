# GDPR Questionnaire Application Routes
# Namespaced under /gdpr to separate from Jumpstart Pro core

Rails.application.routes.draw do
  namespace :gdpr do
    # Questionnaires - Main resource
    resources :questionnaires do
      member do
        patch :publish
        patch :archive
        patch :restore
      end

      # Nested: Sections under Questionnaires
      resources :sections do
        member do
          patch :move
        end

        # Nested: Questions under Sections
        resources :questions
      end

      # Nested: Start a new response for a questionnaire
      resources :responses, only: [:new, :create]
    end

    # Responses - Standalone for viewing/completing
    resources :responses, only: [:index, :show, :edit, :update] do
      member do
        post :submit
      end

      # Nested: Answers within responses
      resources :answers, only: [:create, :update, :destroy]
    end

    # Audit Sessions - View results
    resources :audit_sessions, only: [:index, :show] do
      member do
        post :complete
      end
    end

    # Compliance Areas - Reference data
    resources :compliance_areas, only: [:index, :show]

    # Dashboard - Overview
    root to: "questionnaires#index"
  end
end
