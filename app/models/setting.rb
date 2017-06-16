# Settings are a fairly generic model intended to let us store configuration for
# pretty much anything in the database. A setting can have a default value and
# an array of possible values it could take when it's linked to a
# SettingTemplate (as all settings in our system will be for the time being)
class Setting < ActiveRecord::Base
  include SettingValues

  belongs_to :owner, polymorphic: true

  belongs_to :setting_template

  after_initialize :set_default_value

  delegate :possible_setting_values, to: :setting_template, allow_nil: true

  validates :value,
            inclusion: {
              in: ->(s) { s.possible_setting_values.map(&:value) }
            },
            if: -> { possible_setting_values.present? }

  def set_default_value
    self.value ||= setting_template.value if setting_template_id.present?
  end
end
