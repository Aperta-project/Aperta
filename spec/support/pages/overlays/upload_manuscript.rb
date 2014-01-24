class UploadManuscriptOverlay < CardOverlay
  def upload_word_doc
    session.execute_script "$('#upload_file').css('position', 'relative')"
    attach_file 'upload_file', Rails.root.join('spec/fixtures/about_turtles.docx')
    session.execute_script "$('#upload_file').css('position', 'absolute')"
    sleep 5
  end
end
