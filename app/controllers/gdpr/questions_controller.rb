module Gdpr
  class QuestionsController < BaseController
    before_action :set_questionnaire
    before_action :set_section
    before_action :set_question, only: [:edit, :update, :destroy]

    def index
      @questions = @section.questions.ordered.includes(:answer_choices)
    end

    def new
      @question = @section.questions.new
    end

    def create
      @question = @section.questions.new(question_params)

      if @question.save
        redirect_to gdpr_questionnaire_section_questions_path(@questionnaire, @section),
                    notice: "Question created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @question.update(question_params)
        redirect_to gdpr_questionnaire_section_questions_path(@questionnaire, @section),
                    notice: "Question updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @question.destroy

      redirect_to gdpr_questionnaire_section_questions_path(@questionnaire, @section),
                  notice: "Question deleted successfully"
    end

    private

    def set_questionnaire
      @questionnaire = scoped_questionnaires.find(params[:questionnaire_id])
    end

    def set_section
      @section = @questionnaire.sections.find(params[:section_id])
    end

    def set_question
      @question = @section.questions.find(params[:id])
    end

    def question_params
      params.require(:question).permit(
        :question_text,
        :question_type,
        :help_text,
        :order_index,
        :is_required,
        :weight,
        settings: {},
        answer_choices_attributes: [:id, :choice_text, :score, :order_index, :_destroy]
      )
    end
  end
end
