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

      attachment = task.paper.file
      # A new download is needed to compare the file data
      attachment.file.download! params[:url]
      new_file_hash = Digest::SHA256.hexdigest(attachment.file.file.read)
      if new_file_hash == attachment.previous_file_hash
        TahiPusher::Channel.delay(queue: :eventstream, retry: false).push(
          channel_name: "private-user@#{current_user.id}",
          event_name: 'flashMessage',
          payload: {
            messageType: 'error',
            message: "<b>Duplicate file.</b> Please note: The specified
              file <i>#{attachment.title}</i> has been re-processed.
              <br>If you need to make any changes to your manuscript,
              you can upload again by clicking the <i>Replace</i> link. "
          }
        )
      else
        # Updating the previous_file_hash with the new
        # file_hash when they are not equal
        attachment.update_column(:previous_file_hash, attachment.file_hash)
      end

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
