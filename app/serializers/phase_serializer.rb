class PhaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :position
  has_one :paper, embed: :ids
  has_many :tasks, embed: :ids, include: true
  #has_many :paper_author_tasks, embed: :ids
  # we get => tasks: [1, 2, 3]
  # we want => tasks: [{id: 1, type: 'Foo'}, {id: 2, type 'Bar'}]

  #def tasks
  #  object.tasks.map do |task|
  #    { id: task.id, type: task.type.underscore }
  #  end
  #end
end
