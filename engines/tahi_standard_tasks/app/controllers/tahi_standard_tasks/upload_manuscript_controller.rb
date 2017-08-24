module TahiStandardTasks
  # The UploadManuscriptController is responsible for uploading
  # manuscripts (e.g. files that are doc, docx, etc) for the
  # UploadManuscriptTask.
  class UploadManuscriptController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    # The +upload_manuscript+ action should be used when updating a paper's
    # attached manuscript file from a browser. This is because it enforces
    # permissions at the UploadManuscriptTask-level rather than at the
    # paper-level.
    def upload_manuscript
      requires_user_can :edit, task

      paper = task.paper
      return_status = if paper.sourcefile
                        200 # updated
                      else
                        204 # created
                      end
      attachment = paper.file || paper.create_file
      DownloadManuscriptWorker.download_manuscript(
        paper,
        params[:manuscript_attachment][:s3_url],
        current_user
      )
      render json: attachment, status: return_status, root: 'attachment', serializer: AttachmentSerializer
    end

    private

    def task
      @task ||= UploadManuscriptTask.find(params[:id])
    end
  end
end
