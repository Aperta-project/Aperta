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
