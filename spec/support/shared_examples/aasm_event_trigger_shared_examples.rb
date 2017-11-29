RSpec.shared_examples_for :an_aasm_trigger_model do
  describe 'behaviors on state change' do
    let(:event_name) { "#{described_class.name.downcase}.state_changed.#{to_state}" }
    let(:behavior) { TestBehavior.new(event_name: event_name) }

    context 'when the behavior succeeds' do
      before(:each) do
        expect(Behavior).to receive(:where).with(event_name: event_name).and_return([behavior])
      end

      it 'should run when AASM event is called ' do
        expect(behavior).to receive(:call).with(StateChangeEvent)
        subject
      end
    end

    context 'when the behavior raises an exception' do
      before(:each) do
        expect(Behavior).to receive(:where).with(event_name: event_name).and_raise(StandardError)
      end

      it 'should raise and error and prevent state change' do
        expect { subject }.to raise_error(StandardError)
        expect(state).not_to eq(to_state)
      end
    end
  end
end
