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
        # Create answer choices if provided
        if params[:answer_choices].present?
          create_answer_choices(@question, params[:answer_choices])
        end

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
        # Update answer choices if provided
        if params[:answer_choices].present?
          update_answer_choices(@question, params[:answer_choices])
        end

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
        settings: {}
      )
    end

    def create_answer_choices(question, choices_data)
      choices_data.each_with_index do |choice_data, index|
        question.answer_choices.create(
          choice_text: choice_data[:text],
          score: choice_data[:score],
          order_index: index
        )
      end
    end

    def update_answer_choices(question, choices_data)
      # Simple approach: delete all and recreate
      question.answer_choices.destroy_all
      create_answer_choices(question, choices_data)
    end

    def question_types_options
      Gdpr::Question.question_types.map do |key, value|
        {
          value: key,
          label: key.to_s.titleize,
          description: question_type_description(key)
        }
      end
    end

    def question_type_description(type)
      case type.to_sym
      when :single_choice
        "User selects one option from a list"
      when :multiple_choice
        "User can select multiple options"
      when :text_short
        "Short text input (single line)"
      when :text_long
        "Long text input (multiple lines)"
      when :yes_no
        "Simple yes/no question"
      when :rating_scale
        "Numeric rating (e.g., 1-5 scale)"
      end
    end
  end
end
