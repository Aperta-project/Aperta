require "rails_helper"

describe NedCountries do

  context "with ned enabled", vcr: { cassette_name: "ned_countries" } do
    let(:countries) { NedCountries.new.countries }

    specify { expect(countries).to be_a(Array) }
  end
end
