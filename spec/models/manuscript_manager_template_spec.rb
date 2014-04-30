require 'spec_helper'

describe ManuscriptManagerTemplate do
  let(:name) { nil }
  let(:paper_type) { nil }
  let(:template_json) { {} }
  let(:template_params) { {name: name, paper_type: paper_type, template: template_json} }
  let (:new_template) { ManuscriptManagerTemplate.new template_params }

  describe "validations" do
    it 'must have a name' do
      expect(new_template).to_not be_valid
      expect(new_template).to have(1).errors_on(:name)
    end

    it 'must have a paper type' do
      expect(new_template).to_not be_valid
      expect(new_template).to have(1).errors_on(:paper_type)
    end

    describe 'validating the template' do
      describe "task_types" do
        context "non-empty task types" do
          let(:template_json) do
            {phases: [{name: "Birth", task_types: ["Fertilization"]}]}
          end
          it 'allows only whitelisted task types' do
            expect(new_template).to have(1).errors_on(:task_types)
          end
        end
        context "empty task types" do
          let(:template_json) do
            {phases: [{name: "Birth", task_types: []}]}
          end
          it 'allows empty task types' do
            expect(new_template).to have(0).errors_on(:task_types)
          end
        end
        context "valid task types" do
          let(:template_json) do
            {phases: [{name: "Birth", task_types: [Journal::VALID_TASK_TYPES.first]}]}
          end
          it 'are valid' do
            expect(new_template).to have(0).errors_on(:task_types)
          end
        end
      end

      describe 'phase names' do
        let(:template_json) do
          {phases: [{name: "Birth", task_types: ["Task"]},
                    {name: "Birth", task_types: ["Task"]}]}
        end
        it "doesn't allow duplicate phase names" do
          expect(new_template).to_not be_valid
          expect(new_template).to have(1).errors_on(:phases)
        end
      end
    end
  end

end
