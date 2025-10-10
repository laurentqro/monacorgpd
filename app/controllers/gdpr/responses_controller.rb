module Gdpr
  class ResponsesController < BaseController
    before_action :set_questionnaire, only: [:new, :create]
    before_action :set_response, only: [:show, :edit, :update, :submit]

    def index
      responses_scope = scoped_responses
        .includes(:questionnaire, :respondent)
        .recent

      @pagy, @responses = pagy(responses_scope)
    end

    def new
      @response = @questionnaire.responses.new
      @response.respondent = current_user
    end

    def create
      @response = @questionnaire.responses.new(response_params)
      @response.account = current_account
      @response.respondent = current_user
      @response.started_at = Time.current

      if @response.save
        redirect_to edit_gdpr_response_path(@response),
                    notice: "Assessment started. Please answer the questions below."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      authorize_response
      @sections = @response.questionnaire.sections.ordered.includes(questions: :answer_choices)
      @answers = @response.answers.index_by(&:question_id)
    end

    def edit
      authorize_response
      @sections = @response.questionnaire.sections.ordered.includes(questions: :answer_choices)
      @answers = @response.answers.index_by(&:question_id)
    end

    def update
      authorize_response

      if @response.update(response_params)
        redirect_to edit_gdpr_response_path(@response),
                    notice: "Responses saved"
      else
        @sections = @response.questionnaire.sections.ordered.includes(questions: :answer_choices)
        @answers = @response.answers.index_by(&:question_id)
        render :edit, status: :unprocessable_entity
      end
    end

    def submit
      authorize_response

      if @response.in_progress?
        @response.complete!

        # Create audit session
        audit_session = @response.create_audit_session!(
          account: current_account,
          status: :draft
        )

        # Calculate scores
        audit_session.calculate_overall_score
        audit_session.complete!

        redirect_to gdpr_audit_session_path(audit_session),
                    notice: "Assessment completed! View your compliance score below."
      else
        redirect_to gdpr_response_path(@response),
                    alert: "This assessment has already been completed"
      end
    end

    private

    def set_questionnaire
      @questionnaire = scoped_questionnaires.find(params[:questionnaire_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_questionnaires_path, alert: "Questionnaire not found"
    end

    def set_response
      @response = scoped_responses.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_responses_path, alert: "Response not found"
    end

    def scoped_responses
      Gdpr::Response.for_account(current_account)
    end

    def response_params
      params.require(:response).permit(:notes)
    end

    def authorize_response
      unless @response.account_id == current_account.id
        redirect_to gdpr_responses_path, alert: "Not authorized"
      end
    end
  end
end
