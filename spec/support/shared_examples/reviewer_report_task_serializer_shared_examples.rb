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

RSpec.shared_examples_for :reviewer_report_task_serializer do
  include_context "serialized json"
  let(:user) { FactoryGirl.create(:user) }
  let(:task_class) { described_class.name.gsub(/Serializer$/, '').constantize }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:reviewer_report) do
    FactoryGirl.create(
      :reviewer_report,
      paper: paper,
      decision: decision,
      task: reviewer_report_task
    )
  end
  let(:reviewer_report_task) do
    FactoryGirl.create(
      task_class.name.demodulize.underscore.to_sym,
      paper: paper
    )
  end
  let(:object_for_serializer) { reviewer_report_task }
  let(:decision) { FactoryGirl.create(:decision, :pending, paper: paper) }

  before do
    allow(reviewer_report_task).to receive(:submitted?).and_return true
    allow(reviewer_report_task).to receive(:display_status).and_return :submitted
    allow(user).to receive(:can?).with(:edit, reviewer_report_task).and_return true
    allow(user).to receive(:can?).with(:view, reviewer_report_task).and_return true
    allow(user).to receive(:can?).with(:view, paper).and_return true
    allow(user).to receive(:can?).with(:view_decisions, paper).and_return true
  end

  let(:task_content) { deserialized_content[:task] }
  let(:decisions_content) { deserialized_content[:decisions] }

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash
    expect(task_content).to match(
      hash_including(
        is_submitted: true,
        decision_ids: [decision.id]
      )
    )

    actual_decision_ids = decisions_content.map { |h| h[:id] }
    expect(actual_decision_ids).to contain_exactly(decision.id)
  end

  context 'when there are reports by other users' do
    let(:other_user) { FactoryGirl.create(:user) }
    let!(:other_invitation) { FactoryGirl.create(:invitation, paper: paper, decision: decision, invitee: other_user) }
    let!(:other_reviewer_report) do
      FactoryGirl.create(
        :reviewer_report,
        paper: paper,
        user: other_user,
        decision: decision,
        task: other_reviewer_report_task
      )
    end
    let(:other_reviewer_report_task) do
      FactoryGirl.create(
        task_class.name.demodulize.underscore.to_sym,
        paper: paper
      )
    end

    # In APERTA-11411 it was found that we were sideloading reviewer reports
    # that we should not have been, by a chain of has_many ... include: true
    # directives in serializers. This test, while seeming a little odd, is a
    # regression test against that behavior.
    it 'should not serialize that report' do
      allow(user).to receive(:can?)
        .with(:view, other_reviewer_report_task)
        .and_return false

      expect(deserialized_content[:reviewer_reports].size).to eq(1)
    end
  end
end
