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
end
