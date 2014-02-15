class FigureTaskPresenter < TaskPresenter
  def data_attributes
    super.merge({
      'figures' => task.figure_access_details,
      'figures-path' => paper_figures_path(task.paper)
    })
  end
end
