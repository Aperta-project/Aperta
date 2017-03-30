module TahiStandardTasks
  class UploadSourcefileController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def upload_sourcefile
      requires_user_can :edit, task

      DownloadSourcefileWorker.download(
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
