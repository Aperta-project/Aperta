require "spec_helper"

describe Hash do
  let(:hash) { { a: {b: "b", c: "c"} }}

  it "should return the value of the nested key" do
    expect(hash.get(:a, :b)).to eq("b")
  end

  it "should return nil when nested key isn't found" do
    expect(hash.get(:a, :z)).to be_nil
  end

  it "should return the value of the key" do
    expect(hash.get(:a)).to eq({b: "b", c: "c"})
  end
end
