class SupportingInformationFilesController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  def show
    requires_user_can(:view, file.paper)
    respond_with file
  end

  def create
    requires_user_can(:edit, file.paper)
    file.update_attributes(status: 'processing')
    DownloadAttachmentWorker.perform_async(file.id, params[:url], current_user.id)
    respond_with file
  end

  def update
    requires_user_can(:edit, file.paper)
    file.update_attributes file_params
    respond_with file
  end

  def destroy
    requires_user_can(:edit, file.paper)
    file.destroy
    head :no_content
  end

  def update_attachment
    requires_user_can(:edit, file.paper)
    file.update_attribute(:status, 'processing')
    DownloadAttachmentWorker.perform_async(file.id, params[:url], current_user.id)
    respond_with file
  end

  private

  def file
    @file ||= begin
                if params[:id].present?
                  SupportingInformationFile.find(params[:id])
                else
                  build_new_supporting_information_file
                end
              end
  end

  def build_new_supporting_information_file
    task = TahiStandardTasks::SupportingInformationTask.find(params[:task_id])
    task.supporting_information_files.new(paper_id: task.paper_id)
  end

  def file_params
    params.require(:supporting_information_file).permit(
      :title,
      :caption,
      :label,
      :category,
      :publishable,
      :striking_image,
      :attachment,
      attachment: [])
  end

  def render_404
    head 404
  end
end
