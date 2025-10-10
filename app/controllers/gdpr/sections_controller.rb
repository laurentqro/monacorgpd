module Gdpr
  class SectionsController < BaseController
    before_action :set_questionnaire
    before_action :set_section, only: [:edit, :update, :destroy, :move]

    def new
      @section = @questionnaire.sections.new
    end

    def create
      @section = @questionnaire.sections.new(section_params)

      if @section.save
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Section created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @section.update(section_params)
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Section updated successfully"
      else
        render :edit, status: :unprocessable_entity
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
