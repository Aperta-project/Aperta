# An instance of this model represents a half-finished feature whose
# presence we're still masking from production users. Because of our
# current deployment stack, it is more convenient to enable and
# disable these features in the database than in environment
# variables.
#
# NOTE: To create a NEW feature flag, modify the insert_feature_flags
# rake task! Ditto to remove an unneeded flag once all conditionals
# have been removed.
#
# To turn a feature on or off, visit /admin/feature_previews as a user
# with the site_admin role.
#
class FeatureFlag < ActiveRecord::Base
  # Fields:
  # name: string (acts as ID)
  # active: boolean (true if the incomplete feature should be visible)
  self.primary_key = 'name'
end
