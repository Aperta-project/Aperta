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

describe ParticipationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:participant) { FactoryGirl.create(:user) }
  let(:journal){ FactoryGirl.create(:journal) }
  let!(:paper) do
    FactoryGirl.create(:paper, journal: journal)
  end
  let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

  before do
    Role.ensure_exists(Role::TASK_PARTICIPANT_ROLE, journal: journal) do |role|
      role.ensure_permission_exists(:view_participants, applies_to: Task, states: ['*'])
    end
  end

  describe "#index" do
    let!(:participation1) { task.add_participant(user) }
    let!(:participation2) { task.add_participant(FactoryGirl.create(:user)) }

    subject(:do_request) do
      get :index, {
        format: 'json',
        task_id: task.to_param
      }
    end

    it_behaves_like "an unauthenticated json request"

    context "and the user authorized" do
      before do
        stub_sign_in user
        allow(user).to \
          receive(:can?).with(:view_participants, task).and_return true
      end

      it "returns the task's participations" do
        do_request

        participation_ids = res_body['participations'].map do |participation|
          participation['id']
        end

        expect(res_body['participations'].count).to eq(2)
        expect(participation_ids).to include(participation1.id, participation2.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view_participants, task)
          .and_return false
      end

      it { is_expected.to responds_with(200) }

      it 'responds with an empty list of participations' do
        do_request
        expect(res_body['participations']).to be_empty
      end
    end
  end

  describe "#show" do
    subject(:do_request) do
      get :show, format: 'json', id: participation.to_param
    end

    let!(:participation) { FactoryGirl.create(:assignment, assigned_to: task) }

    it_behaves_like "an unauthenticated json request"

    context "and the user authorized" do
      before do
        stub_sign_in user
        allow(user).to \
          receive(:can?).with(:view_participants, task).and_return true
      end

      it "returns the participation" do
        do_request

        expect(res_body['participation']).to be
        expect(res_body['participation']['id']).to eq(participation.id)
      end

      context "and the participation does not exist" do
        before { participation.delete }
        it { is_expected.to responds_with(404) }
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view_participants, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create, format: :json,
        participation: {user_id: participant.id,
                        task_id: task.id}
    end

    it_behaves_like "an unauthenticated json request"

    context "the user is authorized" do
      before do
        stub_sign_in user
        allow(user).to \
          receive(:can?).with(:manage_participant, task).and_return true
      end

      context "the user does not pass a participant" do
        it "doesn't work" do
          expect {
            xhr :post, :create,
            format: :json,
            participation: {user_id: nil,
                            task_id: task.id}
          }.to_not change { task.participations.count }
        end
      end

      it "creates a new participation" do
        expect { do_request }.to change { task.participations.count }.by(1)
      end

      it "creates an activity" do
        activity = {
          subject: paper,
          message: "Added Contributor: #{participant.full_name}"
        }
        expect(Activity).to receive(:create).with(hash_including(activity))
        do_request
      end

      it 'creates an Role.participant assignment on the task' do
        expect { do_request }.to change { task.participations.count }.by(1)
        expect(task.participations.last).to eq \
          Assignment.where(
            user: participant,
            role: task.journal.task_participant_role,
            assigned_to: task
          ).first
      end

      it "returns the new participation as json" do
        do_request
        expect(response.status).to eq(201)
        expect(res_body["participation"]["id"]).to eq(task.participations.last.id)
      end

      context "participants" do
        let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
        let(:editors_discussion_task) do
          FactoryGirl.create(:editors_discussion_task, paper: paper)
        end
        let(:new_participant) { FactoryGirl.create(:user) }

        subject :do_request do
          post(
            :create,
            format: 'json',
            participation: {
              user_id: new_participant.id,
              task_id: task.id,
              task_type: 'AdHocTask'
            }
          )
        end

        it "calls the task's #notify_new_participant method" do
          expect_any_instance_of(Task).to receive :notify_new_participant
          do_request
        end

        context "when the task type is not EditorDiscussionTask" do
          it "adds an email to the sidekiq queue if new participant != current user" do
            expect do
              do_request
            end.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
          end
        end

        context "when the task type is EditorsDiscussionTask" do
          before do
            allow(user).to \
              receive(:can?).with(:manage_participant, editors_discussion_task)
              .and_return true
          end

          it "sends a different email to the editor participants" do
            expect(UserMailer).to \
              receive_message_chain(:delay, :add_editor_to_editors_discussion)
            post(
              :create,
              format: 'json',
              participation: {
                user_id: new_participant.id, task_id: editors_discussion_task.id
              }
            )
          end

          it "does not add an email to the sidekiq queue if new participant is the current user" do
            expect do
              post(
                :create,
                format: 'json',
                participation: { user_id: user.id, task_id: task.id }
              )
            end.to_not change(Sidekiq::Extensions::DelayedMailer.jobs, :size)
          end
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_participant, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "DELETE #destroy" do
    subject(:do_request) do
      delete :destroy, format: :json, id: participation.id
    end

    let!(:participation) do
      FactoryGirl.create(
        :assignment,
        assigned_to: task,
        role: task.journal.task_participant_role,
        user: participant
      )
    end

    it_behaves_like "an unauthenticated json request"

    context "the user is authorized" do
      before do
        stub_sign_in user
        allow(user).to \
          receive(:can?).with(:manage_participant, task).and_return true
      end

      context "with a valid participation id" do
        subject(:do_request) do
          delete :destroy, format: :json, id: participation.id
        end

        it "destroys the associated participation" do
          expect {
            do_request
          }.to change { task.participations.count }.by -1
        end

        it "creates an activity" do
          expect{ do_request }.to change(Activity, :count).by(1)
        end
      end

      context "with an invalid participation id" do
        subject(:do_request) do
          delete :destroy, format: :json, id: 9999
        end

        it "returns a 404" do
          expect(do_request.status).to eq(404)
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_participant, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  context "participants" do
    subject :do_request do
      post :create, format: 'json', participation: { user_id: new_participant.id, task_id: task.id, task_type: 'AdHocTask' }
    end

    let(:editors_discussion_task) do
      FactoryGirl.create(:editors_discussion_task, paper: paper)
    end
    let(:new_participant) { FactoryGirl.create(:user) }

    it_behaves_like "an unauthenticated json request"

    context "the user is authorized" do
      before do
        stub_sign_in user
        allow(user).to \
          receive(:can?).with(:manage_participant, task).and_return true
      end

      it "calls the task's #notify_new_participant method" do
        expect_any_instance_of(Task).to receive :notify_new_participant
        do_request
      end

      context "when the task type is not EditorDiscussionTask" do
        it "adds an email to the sidekiq queue if new participant is not current user" do
          expect { do_request }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
        end
      end

      context "when the task type is EditorsDiscussionTask" do
        before do
          allow(user).to \
            receive(:can?).with(:manage_participant, editors_discussion_task).and_return true
        end

        it "sends a different email to the editor participants" do
          expect(UserMailer).to receive_message_chain(:delay, :add_editor_to_editors_discussion)
          post :create, format: 'json', participation: { user_id: new_participant.id, task_id: editors_discussion_task.id }
        end
      end

      it "does not add an email to the sidekiq queue if new participant is the current user" do
        expect {
          post :create, format: 'json', participation: { user_id: user.id, task_id: task.id }
        }.to_not change(Sidekiq::Extensions::DelayedMailer.jobs, :size)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_participant, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
