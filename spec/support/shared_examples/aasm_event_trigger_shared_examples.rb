# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
