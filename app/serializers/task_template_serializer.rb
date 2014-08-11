class TaskTemplateSerializer < ActiveModel::Serializers
  attributes :id, :title, :template

  has_one :phase_template, embed: :id, include: true
  has_one :journal_task_type, embed: :id, include: true
end
