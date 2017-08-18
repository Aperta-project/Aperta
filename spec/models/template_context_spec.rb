require 'rails_helper'

describe TemplateContext do
  describe '.build_merge_fields' do
    TemplateContext.descendants.each do |tc|
      it " #{tc.name} has merge fields" do
        expect(tc.build_merge_fields.any?).to be_truthy
      end
    end
  end
end
