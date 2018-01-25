module UserDevise
  extend ActiveSupport::Concern

  included do
    # allow login using email address or username
    def self.find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
      else
        super
      end
    end
  end
end
