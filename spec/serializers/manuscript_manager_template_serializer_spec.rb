require 'spec_helper'

describe ManuscriptManagerTemplateSerializer do
  describe '#template' do
    let(:mmt) { FactoryGirl.create(:manuscript_manager_template, template: {
      phases: [{name: "Only Phase"}]
    }) }
    let(:serializer) { ManuscriptManagerTemplateSerializer.new(mmt) }

    it 'turns nil task types into empty arrays' do
      expect(serializer.template).to eq(
        {"phases" => [{"name" => "Only Phase", "task_types" => []}]}
      )
    end
  end
end
