class AdhocOverlay < CardOverlay

  def add_content_button
    find('.adhoc-content-toolbar .fa-plus')
  end

  def replace_image_button
    find(".thumbnail-preview").hover
    # binding.pry
    find('.replace')
  end

  def replace_image(file_name)
    # replace_image_button.click
    file_upload(file_name)
  end

  def attach_and_upload_file(file_name)
    add_content_button.click
    file_upload(file_name)
  end

  def file_upload(file_name)
    upload_file(element_id: "file_attachment",
                file_name: file_name,
                sentinel: Proc.new{ Attachment.count })
  end
end
