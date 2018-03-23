class PhaseTemplateSerializer < AuthzSerializer
  attributes :id, :name, :position

  has_many :task_templates, embed: :ids, include: true
  has_one :manuscript_manager_template, embed: :ids, include: false
end
