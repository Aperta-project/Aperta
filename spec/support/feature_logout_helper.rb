# FeatureLogoutHelper augments Warden::Test::Helpers#logout so it works
# when running :js/:selenium specs.
#
# It must be included after Warden::Test::Helpers
module FeatureLogoutHelper
  def logout(*scopes)
    if self.class.respond_to?(:metadata)
      if self.class.metadata[:js] || self.class.metadata[:selenium]
        Page.new.sign_out
      end
    end
    super
  end
end
