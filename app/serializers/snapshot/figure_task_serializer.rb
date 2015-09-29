module Snapshot
  class FigureTaskSerializer < BaseTaskSerializer

    def snapshot_properties
      paper = Paper.find(@task.paper)
      properties = []
      paper.figures.order(:id).each do |figure|
        properties << { figure: snapshot_figure(figure) }
      end
      properties
    end

    def snapshot_figure figure
      properties = []
      attachment_serializer = Snapshot::AttachmentSerializer.new figure.attachment
      properties << ["attachment", attachment_serializer.snapshot]
      properties << snapshot_property("title", "text", figure.title)
      properties << snapshot_property("caption", "text", figure.caption)
      properties << snapshot_property("status", "text", figure.status)
    end
  end
end
