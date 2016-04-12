# Serializes Figure Tasks
class Snapshot::FigureTaskSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    model.paper.figures.order(:id).map do |figure|
      Snapshot::FigureSerializer.new(figure).as_json
    end
  end
end
