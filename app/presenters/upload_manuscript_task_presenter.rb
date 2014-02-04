class UploadManuscriptTaskPresenter < TaskPresenter
  def data_attributes
    super.merge 'upload-paper-path' => upload_paper_path(task.paper, format: :json)
  end
end
