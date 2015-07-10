require "rails_helper"

describe NedProfile do

  context "with a valid cas id", vcr: { cassette_name: "ned" } do
    let(:profile) { NedProfile.new(cas_id: "00000000-f8d2-4a8d-b8e4-21aa01a81aab") }

    specify { expect(profile.first_name).to eq("Testy") }
    specify { expect(profile.last_name).to eq("McTesterson") }
    specify { expect(profile.email).to eq("testy@example.com") }
    specify { expect(profile.ned_id).to eq(2) }
    specify { expect(profile.display_name).to eq("nicename") }
    specify { expect(profile).to be_verified }
    specify { expect(profile.to_h).to be_a(Hash) }
  end

  context "with a invalid cas id", vcr: { cassette_name: "ned" } do
    let(:profile) { NedProfile.new(cas_id: "something-invalid") }

    specify { expect { profile.first_name }.to raise_error(NedProfileConnectionError) }
  end
end
