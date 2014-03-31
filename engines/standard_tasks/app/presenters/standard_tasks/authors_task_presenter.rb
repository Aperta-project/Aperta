class StandardTasks::AuthorsTaskPresenter < TaskPresenter
  def data_attributes
    super.merge 'authors' => task.authors
  end
end
