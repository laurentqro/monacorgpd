module Gdpr
  class QuestionnairesController < BaseController
    before_action :set_questionnaire, only: [:show, :edit, :update, :destroy, :publish, :archive, :restore]

    def index
      @questionnaires = scoped_questionnaires
        .active
        .includes(:creator, :sections)
        .order(created_at: :desc)

      render inertia: "Gdpr/Questionnaires/Index", props: {
        questionnaires: @questionnaires.as_json(
          include: {
            creator: { only: [:id, :name, :email] },
            sections: { only: [:id, :title] }
          },
          methods: [:deleted?]
        ),
        statuses: Gdpr::Questionnaire.statuses.keys
      }
    end

    def show
      authorize @questionnaire

      render inertia: "Gdpr/Questionnaires/Show", props: {
        questionnaire: @questionnaire.as_json(
          include: {
            creator: { only: [:id, :name, :email] },
            sections: {
              include: {
                questions: {
                  include: :answer_choices
                }
              }
            }
          }
        )
      }
    end

    def new
      @questionnaire = scoped_questionnaires.new

      render inertia: "Gdpr/Questionnaires/New", props: {
        categories: categories_options
      }
    end

    def create
      @questionnaire = scoped_questionnaires.new(questionnaire_params)
      @questionnaire.creator = current_user

      if @questionnaire.save
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Questionnaire created successfully"
      else
        redirect_to new_gdpr_questionnaire_path,
                    inertia: { errors: @questionnaire.errors }
      end
    end

    def edit
      authorize @questionnaire

      render inertia: "Gdpr/Questionnaires/Edit", props: {
        questionnaire: @questionnaire,
        categories: categories_options
      }
    end

    def update
      authorize @questionnaire

      if @questionnaire.update(questionnaire_params)
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Questionnaire updated successfully"
      else
        redirect_to edit_gdpr_questionnaire_path(@questionnaire),
                    inertia: { errors: @questionnaire.errors }
      end
    end

    def destroy
      authorize @questionnaire

      @questionnaire.soft_delete

      redirect_to gdpr_questionnaires_path,
                  notice: "Questionnaire deleted successfully"
    end

    def publish
      authorize @questionnaire

      if @questionnaire.published!
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Questionnaire published successfully"
      else
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    alert: "Failed to publish questionnaire"
      end
    end

    def archive
      authorize @questionnaire

      if @questionnaire.archived!
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    notice: "Questionnaire archived successfully"
      else
        redirect_to gdpr_questionnaire_path(@questionnaire),
                    alert: "Failed to archive questionnaire"
      end
    end

    def restore
      authorize @questionnaire

      @questionnaire.restore

      redirect_to gdpr_questionnaire_path(@questionnaire),
                  notice: "Questionnaire restored successfully"
    end

    private

    def set_questionnaire
      @questionnaire = scoped_questionnaires.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to gdpr_questionnaires_path, alert: "Questionnaire not found"
    end

    def questionnaire_params
      params.require(:questionnaire).permit(
        :title,
        :description,
        :category,
        :status
      )
    end

    def categories_options
      [
        { value: "gdpr", label: "GDPR Compliance" },
        { value: "data_mapping", label: "Data Mapping" },
        { value: "vendor_assessment", label: "Vendor Assessment" },
        { value: "dpia", label: "Data Protection Impact Assessment" },
        { value: "other", label: "Other" }
      ]
    end

    def authorize(record)
      # Will implement with Pundit policies
      # For now, just check account ownership
      unless record.account_id == current_account.id
        redirect_to gdpr_questionnaires_path, alert: "Not authorized"
      end
    end
  end
end
