require 'rails_helper'

class TestScenario < PaperScenario; end

describe PaperScenario do
  describe '#scenario_name' do
    subject { described_class.scenario_name }

    it 'should print out a friendly scenario name' do
      should eq 'Manuscript'
    end
  end
end

describe TestScenario do
  subject { described_class }
  it { should < PaperScenario }

  describe '#scenario_name' do
    before do
      allow(TemplateContext).to receive(:scenarios).and_return('Test' => TestScenario)
    end
    subject { described_class.scenario_name }
    it { should eq 'Test' }
  end
end
