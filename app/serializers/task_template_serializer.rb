class TaskTemplateSerializer < AuthzSerializer
  attributes :id, :template, :title, :position, :settings_enabled, :all_settings

  has_one :phase_template, embed: :id
  has_one :card, embed: :id, include: true
  has_one :journal_task_type, embed: :id, include: true

  def settings_enabled
    object.setting_templates.present?
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
