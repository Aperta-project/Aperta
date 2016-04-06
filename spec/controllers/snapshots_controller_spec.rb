require 'rails_helper'

describe SnapshotsController do
  let(:owner) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
  let(:task) do
    FactoryGirl.create(:ethics_task, paper: paper, participants: [owner])
  end
  let(:preview) { SnapshotService.new(paper).preview(task) }

  describe '#index' do
    before do
      SnapshotService.new(paper).snapshot!(task)
      sign_in owner
    end

    subject(:do_request) do
      get :index,
          format: 'json',
          task_id: task.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    it "returns the task's snapshots" do
      do_request
      expect(res_body['snapshots'].count).to eq(2)
      ids = res_body['snapshots'].map { |snapshot| snapshot['id'] }
      expect(ids).to include(task.snapshots[0].id)
    end
  end

  context 'roles and permissions' do
    before do
      SnapshotService.new(paper).snapshot!(task)
    end

    subject(:do_request) do
      get :index,
          format: 'json',
          task_id: task.to_param
    end

    it 'works with permission' do
      sign_in owner
      do_request

      expect(response.status).to eq(200)
    end

    it 'returns a 403 without permission' do
      sign_in other_user # other_user does not have permission to view the task
      do_request

      expect(response.status).to eq(403)
    end
  end
end
