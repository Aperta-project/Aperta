module TahiStandardTasks
  class UploadSourcefileController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def upload_sourcefile
      requires_user_can :edit, task

      paper = task.paper
      return_status = if paper.sourcefile
                        200 # updated
                      else
                        204 # created
                      end
      attachment = paper.sourcefile || paper.create_sourcefile
      DownloadSourcefileWorker.download(
        paper,
        params[:sourcefile_attachment][:s3_url],
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
