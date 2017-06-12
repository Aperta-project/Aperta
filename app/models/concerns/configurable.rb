# Configurable models have related Settings stored in the database
module Configurable
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :owner
  end

  # registered settings for a given key will be global ones (where journal id is
  # nil) or ones where journal is this Configurable's journal
  def registered_settings
    RegisteredSetting.where(key: registered_settings_key,
                            journal: [nil, journal])
  end

  def registered_settings_key
    e = "Please implement registered_settings_key for #{self.class.name}"
    raise NotImplementedError, e
  end

  def setting(name)
    settings.find_by(name: name) || begin

      r = registered_settings.find_by!(setting_name: name)
      settings.find_or_create_by!(name: r.setting_name,
                                  type: r.setting_klass,
                                  owner: self)
    end
  end
end
