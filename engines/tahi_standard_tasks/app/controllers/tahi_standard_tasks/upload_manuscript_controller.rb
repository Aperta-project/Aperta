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
      DownloadManuscriptWorker.download_manuscript(
        task.paper,
        params[:url],
        current_user
      )

      head 204
    end

    private

    def task
      @task ||= UploadManuscriptTask.find(params[:id])
    end
  end
end
