module Gdpr
  class SectionsController < BaseController
    before_action :set_questionnaire
    before_action :set_section, only: [:show, :edit, :update, :destroy, :move]

    def index
      @sections = @questionnaire.sections.ordered.includes(:questions)

      render inertia: "Gdpr/Sections/Index", props: {
        questionnaire: @questionnaire.as_json(only: [:id, :title]),
        sections: @sections.as_json(
          include: {
            questions: { only: [:id, :question_text, :question_type, :is_required] }
          }
        )
      }
    end

    def show
      render inertia: "Gdpr/Sections/Show", props: {
        questionnaire: @questionnaire.as_json(only: [:id, :title]),
        section: @section.as_json(
          include: {
            questions: {
              include: :answer_choices
            }
          }
        )
      }
    end

    def new
      @section = @questionnaire.sections.new

      render inertia: "Gdpr/Sections/New", props: {
        questionnaire: @questionnaire.as_json(only: [:id, :title]),
        section: @section
      }
    end

    def create
      @section = @questionnaire.sections.new(section_params)

      if @section.save
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Section created successfully"
      else
        redirect_to new_gdpr_questionnaire_section_path(@questionnaire),
                    inertia: { errors: @section.errors }
      end
    end

    def edit
      render inertia: "Gdpr/Sections/Edit", props: {
        questionnaire: @questionnaire.as_json(only: [:id, :title]),
        section: @section
      }
    end

    def update
      if @section.update(section_params)
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Section updated successfully"
      else
        redirect_to edit_gdpr_questionnaire_section_path(@questionnaire, @section),
                    inertia: { errors: @section.errors }
      end
    end

    def destroy
      @section.destroy

      redirect_to gdpr_questionnaire_path(@questionnaire),
                  notice: "Section deleted successfully"
    end

    def move
      new_position = params[:position].to_i

      if new_position >= 0
        @section.update(order_index: new_position)

        # Reorder other sections
        @questionnaire.sections.where.not(id: @section.id).order(:order_index).each_with_index do |section, index|
          adjusted_index = index >= new_position ? index + 1 : index
          section.update_column(:order_index, adjusted_index)
        end

        render json: { success: true }
      else
        render json: { success: false, error: "Invalid position" }, status: :unprocessable_entity
      end
    end

    private

    def set_questionnaire
      @questionnaire = scoped_questionnaires.find(params[:questionnaire_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_questionnaires_path, alert: "Questionnaire not found"
    end

    def set_section
      @section = @questionnaire.sections.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_questionnaire_sections_path(@questionnaire),
                  alert: "Section not found"
    end

    def section_params
      params.require(:section).permit(:title, :description, :order_index)
    end
  end
end
