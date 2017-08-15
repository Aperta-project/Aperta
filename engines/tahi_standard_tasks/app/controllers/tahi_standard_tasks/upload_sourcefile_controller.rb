module TahiStandardTasks
  class UploadSourcefileController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def upload_sourcefile
      requires_user_can :edit, task

      paper = task.paper
      new_attachment = if paper.sourcefile
                         false
                       else
                         true
                       end
      attachment = paper.sourcefile || paper.create_sourcefile
      DownloadSourcefileWorker.download(
        paper,
        params[:sourcefile_attachment][:s3_url],
        current_user
      )

      if new_attachment
        render json: attachment, status: 201, root: 'attachment', serializer: AttachmentSerializer
      else
        render json: attachment, status: 200, root: 'attachment', serializer: AttachmentSerializer
      end
    end

    private

    def task
      @task ||= UploadManuscriptTask.find(params[:id])
    end
  end
end
