module TahiStandardTasks
  class FunderSerializer < ActiveModel::Serializer
    include CardContentShim

    attributes :additional_comments, :id, :name, :grant_number, :website

    has_one :task, embed: :ids
  end
end
