require 'rails_helper'

describe "data:seed_production_instance" do
  it "seeds stuff" do
    count = NestedQuestion.count
    Rake::Task['data:seed_production_instance'].invoke
    count2 = NestedQuestion.count
    expect(count2).to be == (count)
  end
end
