class AuthorsTaskPresenter < TaskPresenter
  def data_attributes
    super.merge 'authors' => task.authors.to_json
  end
end
