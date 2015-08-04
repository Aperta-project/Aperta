require 'support/sidekiq_helper_methods'

class AdhocOverlay < CardOverlay
  include SidekiqHelperMethods

  def add_content_button
    find('.adhoc-content-toolbar .fa-plus')
  end

  def attach_and_upload_file
    add_content_button.click
    wait_for_attachment_to_upload do
      attach_file 'file_attachment', Rails.root.join('spec', 'fixtures', 'yeti.jpg'), visible: false
    end
    process_sidekiq_jobs
  end

  # wait_for_attachment_to_upload exists because feature specs run multiple
  # threads: a thread for running tests and another for running the app for
  # selenium, etc. Not knowing the order of execution between the threads
  # this is for providing ample time and opportunity for an Attachment
  # to be uploaded and created before moving on in a test.
  def wait_for_attachment_to_upload(seconds=10, &blk)
    Timeout.timeout(seconds) do
      original_count = Attachment.count
      yield
      loop do
        break if Attachment.count != original_count
        sleep 0.25
      end
    end
  end
end
