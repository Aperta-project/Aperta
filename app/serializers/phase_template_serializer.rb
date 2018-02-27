class PhaseTemplateSerializer < AuthzSerializer
  attributes :id, :name, :position

  has_many :task_templates, embed: :ids, include: true
  has_one :manuscript_manager_template, embed: :ids, include: false

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
