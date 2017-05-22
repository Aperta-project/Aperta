# RegisteredSetting is the mapping between
# an instance of a thing and the type of settings that
# it should have.
#
# For instance, the SimilarityCheck Card (in this case meaning a Card whose name
# is 'SimilarityCheck') has an IthenticateAutomation setting that needs to be
# edited from a TaskTemplate associated to the card. The IthenticateAutomation
# setting has its own special class (Setting::IthenticateAutomation) since the
# ithenticate settings are an enumeration of values that need special
# validation. RegisteredSetting will map from a key (in this case
# 'TaskTemplate:SimilarityCheck') to the names and classes of the settings for
# that key ('Setting::IthenticateAutomation' and 'ithenticate')
#
# Defaults for a given setting are handled by the Setting subclass itself.
# RegisteredSetting is just a mapping to a Setting class and name Note that some
# settings will be 'global', and some will be associated to a specific journal.
# Initially we're only using global settings.
class RegisteredSetting < ActiveRecord::Base
  belongs_to :journal

  validates :journal, presence: true, if: -> { !global }
end
