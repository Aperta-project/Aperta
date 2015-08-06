class PhaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :position, :task_positions
  has_one :paper, embed: :ids
  has_many :tasks, embed: :ids, include: true, polymorphic: true

  def tasks
    object.tasks_by_position
  end

end
