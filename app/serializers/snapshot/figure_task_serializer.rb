class Snapshot::FigureTaskSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    model.paper.figures.order(:id).map do |figure|
      snapshot_figure(figure)
    end
  end

  def snapshot_figure(figure)
    figure_children = [
      snapshot_property("file", "text", figure[:attachment]),
      snapshot_property("title", "text", figure.title),
    ]

    { name: "figure", type: "properties", children: figure_children }
  end
end
