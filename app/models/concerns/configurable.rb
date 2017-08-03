# Configurable models have related Settings stored in the database
module Configurable
  extend ActiveSupport::Concern

  # even though a configurable has_many settings,
  # accessing any given setting shouldn't happen through the
  # has_many directly, but rather through the `setting` method
  included do
    has_many :settings, as: :owner, dependent: :destroy
  end

  # setting templates for a given key will be global ones (where journal id is
  # nil) or ones where journal is this Configurable's journal
  def setting_templates
    SettingTemplate.where(key: setting_template_key,
                          journal: [nil, journal])
  end

  def setting_template_key
    e = "Please implement setting_template_key for #{self.class.name}"
    raise NotImplementedError, e
  end

  # A Configurable can have many settings. A given setting can be accessed by
  # its name. Settings are lazily created when they are needed. To look up a
  # setting, a configurable has a setting_template_key that needs to be
  # defined first. Check `TaskTemplate` for an example. The defaults and
  # validations for a given type of setting are handled by the Setting class
  # itself. The RegisteredSetting is just a simple mapping between a string key
  # and the Setting class name.
  def setting(name)
    settings.find_by(name: name) || begin
      t = setting_templates.find_by!(setting_name: name)

      setting_args = {
        name: t.setting_name,
        type: t.setting_klass,
        setting_template: t,
        value_type: t.value_type,
        owner: self
      }

      settings.create!(setting_args) do |setting|
        # due to some init/AR/meta issues in the original implementation :(
        setting.value = t.value
      end
    end
  end
end
