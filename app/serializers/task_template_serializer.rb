class TaskTemplateSerializer < ActiveModel::Serializer
  attributes :id, :template, :title, :position, :settings_enabled, :settings, :setting_names

  has_one :phase_template, embed: :id
  has_one :card, embed: :id, include: true
  has_one :journal_task_type, embed: :id, include: true

  def settings_enabled
    object.setting_templates.present?
  end

  def setting_names
    object.setting_templates.map(&:setting_name)
  end
end
