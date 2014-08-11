class PhaseTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :task_templates, embed: :ids, include: true
end
