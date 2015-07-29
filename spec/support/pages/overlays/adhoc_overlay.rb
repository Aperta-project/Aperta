require 'support/sidekiq_helper_methods'

class AdhocOverlay < CardOverlay
  include SidekiqHelperMethods

  def add_content_button
    find('.adhoc-content-toolbar .fa-plus')
  end

  def attach_and_upload_file
    add_content_button.click
    attach_file 'file_attachment', Rails.root.join('spec', 'fixtures', 'yeti.jpg'), visible: false
    process_sidekiq_jobs
  end
end
