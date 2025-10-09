module Gdpr
  class ResponsesController < BaseController
    before_action :set_questionnaire, only: [:new, :create]
    before_action :set_response, only: [:show, :edit, :update, :submit]

    def index
      @responses = scoped_responses
        .includes(:questionnaire, :respondent)
        .order(created_at: :desc)

      render inertia: "Gdpr/Responses/Index", props: {
        responses: @responses.as_json(
          include: {
            questionnaire: { only: [:id, :title, :category] },
            respondent: { only: [:id, :name, :email] }
          },
          methods: [:completion_percentage, :duration]
        )
      }
    end

    def show
      render inertia: "Gdpr/Responses/Show", props: {
        response: @response.as_json(
          include: {
            questionnaire: {
              include: {
                sections: {
                  include: {
                    questions: {
                      include: :answer_choices
                    }
                  }
                }
              }
            },
            answers: { include: :question }
          },
          methods: [:completion_percentage, :duration]
        )
      }
    end

    def new
      @response = scoped_responses.new(
        questionnaire: @questionnaire,
        respondent: current_user
      )

      render inertia: "Gdpr/Responses/Take", props: {
        questionnaire: @questionnaire.as_json(
          include: {
            sections: {
              include: {
                questions: {
                  include: :answer_choices
                }
              }
            }
          }
        ),
        response: @response
      }
    end

    def create
      @response = scoped_responses.new(
        questionnaire: @questionnaire,
        respondent: current_user,
        started_at: Time.current
      )

      if @response.save
        redirect_to edit_gdpr_response_path(@response),
                    notice: "Response started successfully"
      else
        redirect_to new_gdpr_questionnaire_response_path(@questionnaire),
                    inertia: { errors: @response.errors }
      end
    end

    def edit
      render inertia: "Gdpr/Responses/Take", props: {
        questionnaire: @response.questionnaire.as_json(
          include: {
            sections: {
              include: {
                questions: {
                  include: :answer_choices
                }
              }
            }
          }
        ),
        response: @response.as_json(
          include: :answers
        )
      }
    end

    def update
      if save_answers
        if params[:submit]
          redirect_to submit_gdpr_response_path(@response),
                      notice: "Answers saved"
        else
          render json: { success: true, message: "Progress saved" }
        end
      else
        render json: { success: false, errors: "Failed to save answers" },
               status: :unprocessable_entity
      end
    end

    def submit
      if @response.in_progress?
        @response.complete!

        # Create audit session
        audit_session = @response.build_audit_session(account: current_account)
        audit_session.save

        redirect_to gdpr_response_path(@response),
                    notice: "Response submitted successfully"
      else
        redirect_to gdpr_response_path(@response),
                    alert: "Response already submitted"
      end
    end

    private

    def set_questionnaire
      @questionnaire = scoped_questionnaires.published.find(params[:questionnaire_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_questionnaires_path,
                  alert: "Questionnaire not found or not published"
    end

    def set_response
      @response = scoped_responses.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_responses_path, alert: "Response not found"
    end

    def save_answers
      answers_params = params[:answers] || []
      success = true

      answers_params.each do |answer_data|
        answer = @response.answers.find_or_initialize_by(
          question_id: answer_data[:question_id]
        )

        answer.answer_value = answer_data[:answer_value]
        success = false unless answer.save

        # Calculate and save score if applicable
        answer.calculate_and_save_score! if answer.persisted?
      end

      success
    end
  end
end
