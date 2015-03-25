module TahiSupportingInformation
  class FilesController < ::ApplicationController
    respond_to :json
    before_action :authenticate_user!
    before_action :enforce_policy

    def create
      file.update_attributes(status: "processing")
      ::TahiSupportingInformation::DownloadSupportingInfoWorker.perform_async(file.id, params[:url])
      respond_with file
    end

    def update
      file.update_attributes file_params
      respond_with file
    end

    def destroy
      file.destroy
      head :no_content
    end

    private

    def paper
      @paper ||= Paper.find(params[:paper_id])
    end

    def file
      @file ||= begin
        if params[:id].present?
          ::TahiSupportingInformation::File.find(params[:id])
        else
          paper.supporting_information_files.new
        end
      end
    end

    def enforce_policy
      authorize_action!(resource: file)
    end

    def file_params
      params.require(:supporting_information_file).permit(:title, :caption, :attachment, attachment: [])
    end

    def render_404
      head 404
    end
  end
end
