RSpec.shared_examples_for :an_aasm_trigger_model do
  describe 'behaviors on state change' do
    let(:event_name) { "#{described_class.name.downcase}.state_changed.#{to_state}" }
    let(:behavior) { TestBehavior.new(journal: journal, event_name: event_name).tap(&:save!) }

    before(:each) do
      allow(paper.journal.behaviors).to receive(:where).with(event_name: event_name).and_return([behavior])
    end

    context 'when the behavior succeeds' do
      it 'should run when AASM event is called ' do
        expect(behavior).to receive(:call).with(StateChangeEvent)
        subject
      end
    end

    context 'when the behavior raises an exception' do
      it 'should raise and error and prevent state change' do
        expect(behavior).to receive(:call).and_raise(StandardError)
        expect { subject }.to raise_error(StandardError)
        expect(state).not_to eq(to_state)
      end
    end
  end
end
