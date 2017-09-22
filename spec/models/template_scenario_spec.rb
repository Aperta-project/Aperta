require 'rails_helper'

describe TemplateScenario do
  describe '.merge_fields' do
    TemplateScenario.descendants.each do |ts|
      it "#{ts.name} presents available merge fields in the email template admin form" do
        # Scenario merge fields contain contexts with child merge fields
        # If we ever create a scenario with only simple merge fields this test will become inadequate
        expect(ts.merge_fields.any? { |d| d.key?(:children) }).to be_truthy
      end
    end
  end
end
