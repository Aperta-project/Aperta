class AdhocOverlay < CardOverlay

  def upload_attachment(file_name)
    upload_file(element_id: 'file',
                file_name: file_name,
                sentinel: proc { Attachment.count })
  end

  def replace_attachment(file_name)
    within('.attachment-item') do
      file_input_id = page.find('input[type=file]', visible: false)[:id]
      session.execute_script "$('##{file_input_id}').css('display', 'block')"
      upload_file(element_id: file_input_id,
                  file_name: file_name,
                  sentinel: proc { Attachment.last.status })
      session.execute_script "$('##{file_input_id}').css('display', 'none')"
    end
  end
end
