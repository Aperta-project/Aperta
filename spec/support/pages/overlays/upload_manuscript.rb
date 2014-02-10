class UploadManuscriptOverlay < CardOverlay
  def upload_word_doc
    attach_file 'upload_file', Rails.root.join('spec/fixtures/about_turtles.docx'), visible: false
    sleep 5
  end
end
