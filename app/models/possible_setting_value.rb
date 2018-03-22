# PossibleSettingValues belong to a SettingTemplate
class PossibleSettingValue < ActiveRecord::Base
  include ViewableModel
  include SettingValues
  belongs_to :setting_template
end
