# An instance of this model represents a half-finished feature whose
# presence we're still masking from production users. Because of our
# current deployment stack, it is more convenient to enable and
# disable these features in the database than in environment
# variables.
#
# FeatureFlag[:YOUR_FEATURE] returns a boolean
#
# NOTE: To create a NEW feature flag, modify the create_feature_flags
# rake task! Ditto to remove an unneeded flag once all conditionals
# have been removed.
#
# To turn a feature on or off, visit /admin/feature_flags as a user
# with the site_admin role.
#
class FeatureFlag < ActiveRecord::Base
  # Fields:
  # name: string (acts as ID)
  # active: boolean (true if the incomplete feature should be visible)

  def self.contain_exactly!(flags)
    transaction do
      flags.each do |flag|
        find_or_create_by(name: flag) do |feature|
          feature.active = false
        end
      end
      where.not(name: flags).destroy_all
    end
  end

  # This is a nice bit of sugar, but it also ensures that it's harder
  # to accidentally *set* flags, AND it abstracts away the fact that
  # these are in the database instead of the environment.
  def self.[](flag)
    find_by(name: flag.to_s).try(:active)
  end
end
