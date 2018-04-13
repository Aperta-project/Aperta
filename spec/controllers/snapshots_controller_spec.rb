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

require 'rails_helper'

describe SnapshotsController do
  let(:owner) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }
  let(:paper) { FactoryGirl.create(:paper, :with_creator, :submitted, journal: journal) }
  let(:task) do
    FactoryGirl.create(:custom_card_task, paper: paper, participants: [owner])
  end
  let(:preview) { SnapshotService.new(paper).preview(task) }

  describe '#index' do
    subject(:do_request) do
      get :index,
          format: 'json',
          task_id: task.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in owner
        allow(owner).to receive(:can?)
          .with(:view, task)
          .and_return true
        SnapshotService.new(paper).snapshot!(task)
      end

      it "returns the task's snapshots" do
        do_request
        expect(res_body['snapshots'].count).to eq(2)
        ids = res_body['snapshots'].map { |snapshot| snapshot['id'] }
        expect(ids).to include(task.snapshots[0].id)
      end

      it { is_expected.to responds_with(200) }
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in owner
        allow(owner).to receive(:can?)
          .with(:view, task)
          .and_return false
        SnapshotService.new(paper).snapshot!(task)
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
