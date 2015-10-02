module PlosBioAcademicEditor
  class AcademicEditorsController < ActionController::Base

    before_action :authenticate_user!
    before_action :enforce_policy

    respond_to :json

    def destroy
      respond_with(paper.paper_roles.academic_editors.destroy_all)
    end

    private

    def paper
      @paper ||= current_user.assigned_papers.find(params[:paper_id])
    end

    def enforce_policy
      authorize_action!(paper: paper)
    end
  end
end
