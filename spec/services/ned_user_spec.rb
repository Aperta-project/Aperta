require "rails_helper"

describe NedUser do
  context "with ned enabled", vcr: { cassette_name: "ned_user_good" } do
    let(:email_account?) { NedUser.new.email_has_account?('aperta_person@mailinator.com') }

    specify { expect(email_account?).to be true }
  end

  context "with ned enabled", vcr: { cassette_name: "ned_user_bad" } do
    let(:email_account?) { NedUser.new.email_has_account?('not_there@mailinator.com') }

    specify { expect(email_account?).to be false }
  end
end
