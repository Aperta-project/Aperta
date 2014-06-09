class UploadManuscriptOverlay < CardOverlay
  def upload_word_doc
    attach_file 'upload-files', Rails.root.join('spec/fixtures/about_turtles.docx'), visible: false
  end
end
