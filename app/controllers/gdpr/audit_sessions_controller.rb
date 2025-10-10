module Gdpr
  class AuditSessionsController < BaseController
    before_action :set_audit_session, only: [:show, :complete]

    def index
      audit_sessions_scope = scoped_audit_sessions
        .includes(:response, response: :questionnaire)
        .recent

      @pagy, @audit_sessions = pagy(audit_sessions_scope)
    end

    def show
      authorize_audit_session
      @response = @audit_session.response
      @questionnaire = @response.questionnaire
      @sections = @questionnaire.sections.ordered.includes(questions: :answer_choices)
      @answers = @response.answers.includes(:question).index_by(&:question_id)
      @compliance_area_scores = @audit_session.compliance_area_scores.includes(:compliance_area)
    end

    def complete
      authorize_audit_session

      if @audit_session.draft?
        @audit_session.complete!
        redirect_to gdpr_audit_session_path(@audit_session),
                    notice: "Audit session marked as complete"
      else
        redirect_to gdpr_audit_session_path(@audit_session),
                    alert: "This audit session is already completed"
      end
    end

    private

    def set_audit_session
      @audit_session = scoped_audit_sessions.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_audit_sessions_path, alert: "Audit session not found"
    end

    def scoped_audit_sessions
      Gdpr::AuditSession.for_account(current_account)
    end

    def authorize_audit_session
      unless @audit_session.account_id == current_account.id
        redirect_to gdpr_audit_sessions_path, alert: "Not authorized"
      end
    end
  end
end
