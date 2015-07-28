require 'rails_helper'

describe Institutions, focus: true do
  let(:institutions) { Institutions.instance.matching_institutions "Health" }
  let(:names) { institutions.map { |i| i['name'] } }

  it "returns the parsed hash" do
    expect(names).to include "Adventist University of Health Sciences"
    expect(names).to include "Pennsylvania College of Health Sciences"
    expect(names).to include "Berkeley College School of Health Studies"
  end
end
