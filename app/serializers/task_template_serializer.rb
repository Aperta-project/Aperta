class TaskTemplateSerializer < ActiveModel::Serializer
  attributes :id, :template, :title, :position, :settings, :settings_enabled

  has_one :phase_template, embed: :id
  has_one :card, embed: :id, include: true
  has_one :journal_task_type, embed: :id, include: true

  def settings_enabled
    object.registered_settings.present?
  end
end
