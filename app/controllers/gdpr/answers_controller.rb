module Gdpr
  class AnswersController < BaseController
    before_action :set_response
    before_action :set_answer, only: [:update, :destroy]

    def create
      @answer = @response.answers.find_or_initialize_by(question_id: answer_params[:question_id])
      @answer.answer_value = build_answer_value
      @answer.calculated_score = @answer.calculate_score

      if @answer.save
        render json: {
          success: true,
          answer_id: @answer.id,
          calculated_score: @answer.calculated_score,
          completion_percentage: @response.completion_percentage
        }
      else
        render json: {
          success: false,
          errors: @answer.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def update
      @answer.answer_value = build_answer_value
      @answer.calculated_score = @answer.calculate_score

      if @answer.save
        render json: {
          success: true,
          answer_id: @answer.id,
          calculated_score: @answer.calculated_score,
          completion_percentage: @response.completion_percentage
        }
      else
        render json: {
          success: false,
          errors: @answer.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def destroy
      @answer.destroy
      render json: {
        success: true,
        completion_percentage: @response.completion_percentage
      }
    end

    private

    def set_response
      @response = Gdpr::Response.for_account(current_account).find(params[:response_id])
    rescue ActiveRecord::RecordNotFound
      render json: { success: false, error: "Response not found" }, status: :not_found
    end

    def set_answer
      @answer = @response.answers.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { success: false, error: "Answer not found" }, status: :not_found
    end

    def answer_params
      params.require(:answer).permit(:question_id, :response_id, :choice_id, :text, :value, :rating, choice_ids: [])
    end

    def build_answer_value
      value = {}

      # Single choice
      if params[:answer][:choice_id].present?
        value["choice_id"] = params[:answer][:choice_id].to_i
      end

      # Multiple choice
      if params[:answer][:choice_ids].present?
        value["choice_ids"] = params[:answer][:choice_ids].reject(&:blank?).map(&:to_i)
      end

      # Text answer
      if params[:answer][:text].present?
        value["text"] = params[:answer][:text]
      end

      # Yes/No
      if params[:answer][:value].present?
        value["value"] = params[:answer][:value]
      end

      # Rating
      if params[:answer][:rating].present?
        value["rating"] = params[:answer][:rating].to_i
      end

      value
    end
  end
end
