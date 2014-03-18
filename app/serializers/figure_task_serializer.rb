class FigureTaskSerializer < TaskSerializer
  attributes :figures

  def figures
    "These are my figures"
  end
end
