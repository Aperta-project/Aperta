require 'rails_helper'

describe SnapshotsController do
  let(:owner) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }
  let(:paper) { FactoryGirl.create(:paper, :with_creator, :submitted, journal: journal) }
  let(:task) do
    FactoryGirl.create(:ethics_task, paper: paper, participants: [owner])
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
