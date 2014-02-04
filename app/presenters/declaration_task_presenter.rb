class DeclarationTaskPresenter < TaskPresenter
  def data_attributes
    super.merge({
      'declarations' => task.paper.declarations.map { |d| d.slice(:question, :answer, :id) }.to_json
    })
  end
end
