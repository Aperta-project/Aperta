module StandardTasks
  class FigureSerializer < ActiveModel::Serializer
    attributes :id, :filename, :alt, :src, :title, :caption, :preview_src
  end
end
