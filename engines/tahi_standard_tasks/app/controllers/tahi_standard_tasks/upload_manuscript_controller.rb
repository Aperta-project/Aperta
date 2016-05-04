module TahiStandardTasks
  class UploadManuscriptController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

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
