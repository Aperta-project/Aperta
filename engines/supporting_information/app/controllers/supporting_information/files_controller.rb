module SupportingInformation
  class FilesController < ::ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    before_action :authenticate_user!

    def create
      new_file = paper.supporting_information_files.create status: "processing"
      ::SupportingInformation::DownloadSupportingInfo.enqueue(new_file.id, params[:url])
      render json: new_file, root: :supporting_information_file
    end

    def update
      file = ::SupportingInformation::File.find params[:id]
      file.update_attributes file_params
      head :no_content
    end

    def destroy
      if paper_policy.paper.present?
        paper.supporting_information_files.find(params[:id]).destroy
        head :no_content
      else
        head :forbidden
      end
    end

    private
    def file_params
      params.require(:supporting_information_file).permit(:title, :caption, :attachment, attachment: [])
    end

    def paper
      @paper ||= begin
                   paper_policy.paper.tap do |p|
                     raise ActiveRecord::RecordNotFound unless p.present?
                   end
                 end
    end

    def file_paper
      ::SupportingInformation::File.find(params[:id]).paper
    end

    def paper_policy
      @paper_policy ||= ::PaperQuery.new(params[:paper_id].presence || file_paper.id, current_user)
    end

    def render_404
      return head 404
    end
  end
end
