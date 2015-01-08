require 'rails_helper'

describe Institution do
  subject(:names) { Institution.instance.names }

  it "returns the parsed hash" do
    expect(names).to include "A.T. Still University of Health Sciences"
    expect(names).to include "Westmont College"
    expect(names).to include "Virginia State University"
  end
end
