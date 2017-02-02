module TahiStandardTasks
  class UploadSourcefileController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    # The +upload_manuscript+ action should be used when updating a paper's
    # attached manuscript file from a browser. This is because it enforces
    # permissions at the UploadManuscriptTask-level rather than at the
    # paper-level.
    def upload_sourcefile
      requires_user_can :edit, task
      # puts '***Upload sourcefile called'
      # TODO: Figure out what to do here.

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
