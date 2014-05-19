module UserDevise
  extend ActiveSupport::Concern
  included do

    # allow login using email address or username
    def self.find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
      else
        where(conditions).first
      end
    end

    # prefill user data using data being returned from orcid (via omniauth)
    def self.new_with_session(_, session)
      new do |user|
        if data = session["devise.orcid"]
          user.provider   = "orcid"
          user.uid        = data["uid"]
          if bio = data.to_hash.get("info", "orcid_bio", "personal_details")
            user.first_name = bio["given_names"] unless user.first_name.present?
            user.last_name  = bio["family_name"] unless user.last_name.present?
          end
        end
      end
    end

  end
end

