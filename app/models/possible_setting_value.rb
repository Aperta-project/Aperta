# PossibleSettingValues belong to a SettingTemplate
class PossibleSettingValue < ActiveRecord::Base
  include SettingValues
  belongs_to :setting_template
end
