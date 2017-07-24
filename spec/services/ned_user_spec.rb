require "rails_helper"

describe NedUser do
  context "when address is in the NED DB", vcr: { cassette_name: "ned_user_good" } do
    subject(:email_account?) { NedUser.new.email_has_account?('aperta_person@mailinator.com') }

    it { is_expected.to be true }
  end

  context "when the address is not in the NED DB", vcr: { cassette_name: "ned_user_bad" } do
    subject(:email_account?) { NedUser.new.email_has_account?('not_there@mailinator.com') }

    it { is_expected.to be false }
  end
end
