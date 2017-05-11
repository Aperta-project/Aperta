# Configurable models have related Settings stored in the database
module Configurable
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :owner
  end

  def registered_settings
    RegisteredSetting.where(key: registered_settings_key)
  end

  def registered_settings_key
    e = "Please implement registered_settings_key for #{self.class.name}"
    raise NotImplementedError, e
  end

  def setting(name)
    r = registered_settings.find_by!(setting_name: name)
    settings.find_or_create_by!(name: r.setting_name,
                                type: r.setting_klass,
                                owner: self)
  end
end
