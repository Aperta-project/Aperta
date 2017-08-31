require 'rails_helper'

describe TemplateScenario do
  describe '.build_merge_fields' do
    it "All TemplateScenarios have merge fields" do
      TemplateScenario.descendants.each do |ts|
        expect(ts.merge_fields.any?).to be_truthy
      end
    end
  end
end
