class SupportingInformationFilesController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :enforce_policy

  def show
    respond_with file
  end

  def create
    file.update_attributes(status: 'processing')
    DownloadAttachmentWorker.perform_async(file.id, params[:url])
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

  def update_attachment
    file.update_attribute(:status, 'processing')
    DownloadAttachmentWorker.perform_async(file.id, params[:url])
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

  def enforce_policy
    authorize_action!(resource: file)
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
