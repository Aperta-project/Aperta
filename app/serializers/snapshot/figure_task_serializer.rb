class Snapshot::FigureTaskSerializer < Snapshot::BaseTaskSerializer

  private

  def snapshot_properties
    @task.paper.figures.order(:id).map do |figure|
      snapshot_figure(figure)
    end
  end

  def snapshot_figure(figure)
    figure_children = [
      snapshot_property("file", "text", figure[:attachment]),
      snapshot_property("title", "text", figure.title),
      snapshot_property("caption", "text", figure.caption),
      snapshot_property("status", "text", figure.status)
    ]

    { name: "figure", type: "properties", children: figure_children }
  end
end
