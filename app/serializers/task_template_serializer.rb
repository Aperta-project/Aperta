class TaskTemplateSerializer < ActiveModel::Serializer
  attributes :id, :template, :title

  has_one :phase_template, embed: :id
  has_one :journal_task_type, embed: :id, include: true
end
