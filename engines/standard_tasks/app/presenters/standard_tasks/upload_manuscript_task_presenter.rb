module StandardTasks
  class UploadManuscriptTaskPresenter < TaskPresenter
    def data_attributes
      super.merge 'uploadPaperPath' => upload_paper_path(task.paper, format: :json)
    end
  end
end
