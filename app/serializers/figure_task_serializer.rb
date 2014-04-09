class FigureTaskSerializer < TaskSerializer
  attributes :figures

  def figures
    object.figure_access_details
  end

end
