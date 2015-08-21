class AdhocOverlay < CardOverlay

  def add_content_button
    find('.adhoc-content-toolbar .fa-plus')
  end

  def attach_and_upload_file(file_name)
    add_content_button.click
    upload_file(element_id: "file_attachment",
                file_name: file_name,
                sentinel: Proc.new{ Attachment.count })
  end

  def replace_file(file_name)
    find(".thumbnail-preview").hover
    find(".replace").click

    within(".replace") do
      file_input_id = page.find("input[type=file]", visible: false)[:id]
      upload_file(
        element_id: file_input_id,
        file_name: file_name,
        sentinel: Proc.new {
          process_sidekiq_jobs
          Attachment.last[:file] == file_name
        })
    end
  end
end
