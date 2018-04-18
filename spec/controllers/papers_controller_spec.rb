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

describe PapersController do
  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.build_stubbed(:journal) }
  let(:paper) { FactoryGirl.build(:paper) }
  let(:figure) { FactoryGirl.build_stubbed(:figure, paper: paper) }

  describe 'GET index' do
    subject(:do_request) { get :index, format: :json }
    let(:papers) { [active_paper, inactive_paper] }
    let(:active_paper) { FactoryGirl.build_stubbed(:paper, active: true) }
    let(:inactive_paper) { FactoryGirl.build_stubbed(:paper, active: false) }

    it_behaves_like "an unauthenticated json request"

    context 'and the user is signed in' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:filter_authorized).and_return instance_double(
          'Authorizations::Query::Result',
          objects: papers
        )
      end

      it { is_expected.to responds_with 200 }

      it 'returns papers the user has access to' do
        expect(user).to receive(:filter_authorized).with(
          :view,
          Paper.all.includes(:roles, journal: :creator_role)
        ).and_return instance_double(
          'Authorizations::Query::Result',
          objects: papers
        )
        do_request
        expect(res_body['papers'].count).to eq(2)
      end

      it 'includes active and inactive paper count in the response' do
        do_request
        expect(res_body['meta']['total_active_papers']).to eq(1)
        expect(res_body['meta']['total_inactive_papers']).to eq(1)
      end
    end
  end

  describe 'GET show' do
    subject(:do_request) { get :show, id: paper.to_param, format: :json }
    let(:paper) { FactoryGirl.create(:paper, :submitted_lite) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it "responds with the paper" do
        expect(res_body['paper']['id']).to eq(paper.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(404) }
    end

    context "when the user is invited but has not accepted the invitation" do
      let!(:invitation) do
        FactoryGirl.create(:invitation, :invited, invitee: user, paper: paper)
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
        do_request
      end

      it "returns a message to accept the invitation first" do
        expect(response.body).to eq("To access this manuscript, please accept the invitation below.")
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST create - any authenticated user can create a paper' do
    subject(:do_request) do
      post(
        :create,
        paper: paper_params,
        format: :json
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:paper_params) do
      {
        title: 'My new paper',
        journal_id: journal.id,
        paper_type: 'Research'
      }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user is signed in" do
      before do
        stub_sign_in(user)
        allow(PaperFactory).to receive(:create).and_return paper
      end

      it 'creates a paper' do
        expect(PaperFactory).to receive(:create).with(
          paper_params,
          user
        ).and_return paper
        do_request
      end

      it { is_expected.to responds_with(201) }

      it 'responds with the created paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'creates an Activity' do
        expect(Activity).to receive(:paper_created!)
          .with(paper, user: user)
        do_request
      end

      it 'does not call the DownloadManuscriptWorker' do
        expect(DownloadManuscriptWorker).to_not receive(:download)
        do_request
      end

      context 'when a url is present in the paper params' do
        before do
          paper_params['url'] = 'someURL'
        end

        it 'calls DownloadManuscriptWorker' do
          expect(DownloadManuscriptWorker).to receive(:download)
            .with(paper, "someURL", user)
          do_request
        end
      end

      context 'when the paper is invalid' do
        before do
          paper.title = nil
          expect(paper).to be_invalid
        end

        it "doesn't call DownloadManuscriptWorker" do
          expect(DownloadManuscriptWorker).to_not receive(:download)
          do_request
        end

        it "returns a 422" do
          do_request
          expect(response.status).to eq(422)
        end
      end

      it 'returns a forbidden status when DISABLE_SUBMISSIONS feature flag is active' do
        expect(FeatureFlag).to receive(:[]).with('DISABLE_SUBMISSIONS').and_return(true)
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'PUT update' do
    subject(:do_request) do
      put(
        :update,
        id: paper.to_param,
        format: :json,
        paper: { title: 'My new title' }
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access and the paper is editable" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
        allow(Activity).to receive(:paper_edited!)
        paper.update_column(:editable, true)
      end

      it 'updates the paper' do
        do_request
        expect(paper.reload.title).to eq('My new title')
      end

      it { is_expected.to responds_with(204) }

      it 'creates an Activity' do
        expect(Activity).to receive(:paper_edited!).with(paper, user: user)
        do_request
      end
    end

    context "when the user has access and the paper is NOT editable" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
        paper.update_column(:editable, false)
      end

      it { is_expected.to responds_with(422) }

      it 'responds with an error' do
        do_request
        expect(res_body['errors']['editable']).to \
          include('This paper is currently locked for review.')
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET comment_looks' do
    subject(:do_request) do
      get :comment_looks, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:comment) { FactoryGirl.create(:comment, task: task) }
      let!(:other_user) { FactoryGirl.create(:user) }
      let!(:comment_looks) do
        [current_user_comment_look, other_user_comment_look]
      end
      let!(:current_user_comment_look) do
        FactoryGirl.create(:comment_look, comment: comment, user: user)
      end
      let!(:other_user_comment_look) do
        FactoryGirl.create(:comment_look, comment: comment, user: other_user)
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the current user's comment_looks for the paper" do
        expect(res_body['comment_looks'].length).to be(1)
        expect(res_body['comment_looks'][0]['id']).to eq(current_user_comment_look.id)
      end

      it "does not return other user's comment looks on the paper" do
        look_ids = res_body['comment_looks'].map { |hsh| hsh['id'] }
        expect(look_ids).to_not include(other_user_comment_look.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET versioned_texts' do
    subject(:do_request) do
      get :versioned_texts, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:versioned_text) do
        paper.versioned_texts.create!(
          major_version: 1,
          minor_version: 2
        )
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's versioned_texts" do
        versioned_text_ids = res_body['versioned_texts'].map { |hsh| hsh['id'] }
        expect(versioned_text_ids.length).to eq paper.versioned_texts.count
        expect(versioned_text_ids).to \
          contain_exactly(*paper.versioned_texts.map(&:id))
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET workflow_activities' do
    subject(:do_request) do
      get :workflow_activities, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:activities) { [manuscript_activity, workflow_activity] }
      let!(:manuscript_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'manuscript')
      end
      let!(:workflow_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'workflow')
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's workflow & manuscript activities" do
        feed_messages = res_body['feeds'].map { |hsh| hsh['message'] }
        expect(feed_messages.length).to eq paper.activities.length

        expect(feed_messages).to \
          contain_exactly(
            manuscript_activity.message,
            workflow_activity.message
          )
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET manuscript_activities' do
    subject(:do_request) do
      get :manuscript_activities, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:activities) { [manuscript_activity, workflow_activity] }
      let!(:manuscript_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'manuscript')
      end
      let!(:workflow_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'workflow')
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view_recent_activity, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's manuscript activities only" do
        feed_messages = res_body['feeds'].map { |hsh| hsh['messages'] }
        expect(feed_messages.length).to eq \
          paper.activities.where(feed_name: 'manuscript').length
        expect(feed_messages).to \
          contain_exactly(manuscript_activity.message)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view_recent_activity, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET snapshots' do
    subject(:do_request) do
      get :snapshots, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:snapshot_1) { FactoryGirl.build(:snapshot) }
    let(:snapshot_2) { FactoryGirl.build(:snapshot) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        paper.snapshots << snapshot_1 << snapshot_2
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's snapshots" do
        snapshot_ids = res_body['snapshots'].map { |hsh| hsh['id'] }
        expect(snapshot_ids.length).to eq(paper.snapshots.length)
        expect(snapshot_ids).to contain_exactly(snapshot_1.id, snapshot_2.id)
      end
    end
  end

  describe 'GET related_articles' do
    subject(:do_request) do
      get :related_articles, id: paper.id, format: :json
    end
    let!(:paper) { FactoryGirl.create(:paper) }
    let!(:related_article) { FactoryGirl.create(:related_article, paper: paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit_related_articles, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's related_articles" do
        expect(res_body['related_articles'].length).to eq(1)
        expect(res_body['related_articles'][0]['id']).to eq(related_article.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit_related_articles, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT toggle_editable' do
    subject(:do_request) do
      put :toggle_editable, id: paper.id, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
      end

      it "toggles the paper's editable state" do
        paper.update_attribute(:editable, false)
        do_request
        expect(response.status).to eq(200)
        expect(paper.reload.editable).to eq true
      end

      it 'creates an Activity' do
        expect(Activity).to receive(:editable_toggled!)
          .with(paper, user: user)
        do_request
      end

      it 'responds with the paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'responds with 200 OK when the paper is valid' do
        do_request
        expect(response).to responds_with(200)
      end

      it 'responds with 422 Unprocessible Entity when the paper is invalid' do
        paper.update_attribute(:title, '')
        expect(paper.valid?).to be(false)
        do_request
        expect(response).to responds_with(422)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT submit' do
    subject(:do_request) do
      put :submit, id: paper.id, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:submit, paper)
          .and_return true
      end

      context 'Gradual Engagement' do
        before do
          paper.update(gradual_engagement: true)
        end

        it 'makes an initial submission' do
          do_request
          expect(paper.reload).to be_initially_submitted
        end

        it 'creates an activity' do
          expect(Activity).to receive(:paper_initially_submitted!)
            .with(paper, user: user)
          do_request
        end

        context 'when there is a transition error' do
          # for example, due to unprocessed images

          let(:paper_refreshed_from_db) { Paper.find_by_id(paper.id) }

          before do
            expect(Paper).to receive(:find).and_return paper

            allow(paper).to receive(:initial_submit!).and_wrap_original do |method, *arguments|
              method.call(*arguments)
              expect(paper.initially_submitted?).to be true
              # force our transaction to be rolled back
              raise AASM::InvalidTransition.new(paper, "initially_submitted", paper.publishing_state)
            end
          end

          it 'gets rolled back to the unsubmitted state' do
            do_request

            # we pull the paper from the db, since the rollback
            # only affects the db and not the in-memory paper
            expect(paper_refreshed_from_db).to be_unsubmitted
          end

          it 'returns a 422 Unprocessible Entity error' do
            do_request
            expect(response.status).to eq(422)
            expect(response).to be_client_error
            expect(JSON[response.body]['errors'].first).to eq("Failure to transition to initially_submitted")
          end
        end

        context 'when the activity feed fails' do
          it 'submission is rolled back' do
            expect(Activity).to receive(:paper_initially_submitted!).with(paper, user: user) do
              raise
            end

            expect { do_request }.to raise_error StandardError
            expect(paper).to be_unsubmitted
          end
        end
      end

      context 'Checking to submission' do
        let(:paper) { FactoryGirl.create(:paper, publishing_state: 'checking') }

        it 'submits the paper' do
          expect { do_request }.to change { Activity.count }.by(2)
          expect(response.status).to eq(200)
          expect(paper.reload.submitted?).to eq true
        end
      end

      context 'Full submission (not gradual engagement)' do
        it 'submits the paper' do
          do_request
          expect(response.status).to eq(200)
          expect(paper.reload.submitted?).to eq true
          expect(paper.editable).to eq false
        end

        it 'creates an Activity' do
          expect(Activity).to receive(:paper_submitted!)
            .with(paper, user: user)
          do_request
        end

        context 'when there is a transition error' do
          # for example, due to unprocessed images

          let(:paper_refreshed_from_db) { Paper.find_by_id(paper.id) }

          before do
            expect(Paper).to receive(:find).and_return paper

            allow(paper).to receive(:submit!).and_wrap_original do |method, *arguments|
              method.call(*arguments)
              expect(paper.submitted?).to be true
              # force our transaction to be rolled back
              raise AASM::InvalidTransition.new(paper, "submitted", paper.publishing_state)
            end
          end

          it 'gets rolled back to the unsubmitted state' do
            do_request

            # we pull the paper from the db, since the rollback
            # only affects the db and not the in-memory paper
            expect(paper_refreshed_from_db).to be_unsubmitted
          end

          it 'returns a 422 Unprocessible Entity error' do
            do_request
            expect(response.status).to eq(422)
            expect(response).to be_client_error
            expect(JSON[response.body]['errors'].first).to eq("Failure to transition to submitted")
          end
        end

        context 'when the activity feed fails' do
          it 'submission is rolled back' do
            expect(Activity).to receive(:paper_submitted!).with(paper, user: user) do
              raise
            end

            expect { do_request }.to raise_error StandardError
            expect(paper).to be_unsubmitted
          end
        end
      end

      it 'responds with 200 OK' do
        do_request
        expect(response).to responds_with(200)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:submit, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT reactivate' do
    subject(:do_request) do
      put :reactivate, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

    before do
      allow(Paper).to receive(:find_by_id_or_short_doi)
        .with(paper.to_param)
        .and_return paper
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:reactivate, paper)
          .and_return true
        allow(paper).to receive(:reactivate!)
      end

      it 'reactivates the paper' do
        expect(paper).to receive(:reactivate!)
        do_request
      end

      it 'creates an Activity' do
        expect(Activity).to receive(:paper_reactivated!)
          .with(paper, user: user)
        do_request
      end

      it 'responds with the paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'responds with 200 OK' do
        do_request
        expect(response).to responds_with(200)
      end

      context 'when there is a transition error' do
        before do
          expect(Paper).to receive(:find_by_id_or_short_doi).and_return paper

          expect(paper).to receive(:reactivate!) do
            raise AASM::InvalidTransition.new(paper, "whatever_state", paper.publishing_state)
          end
        end

        it 'submission fails' do
          do_request
          expect(paper).to be_unsubmitted
        end

        it 'returns a 422 Unprocessible Entity error' do
          do_request
          expect(response.status).to eq(422)
          expect(response).to be_client_error
          expect(JSON[response.body]['errors'].first).to eq("Failure to transition to whatever_state")
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:reactivate, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT withdraw' do
    subject(:do_request) do
      put :withdraw, id: paper.to_param, format: :json, reason: withdrawal_reason
    end
    let(:paper) { FactoryGirl.build_stubbed(:paper) }
    let(:withdrawal_reason) { 'It was a whoopsie' }

    before do
      allow(Paper).to receive(:find_by_id_or_short_doi)
        .with(paper.to_param)
        .and_return paper
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:withdraw, paper)
          .and_return true
        allow(paper).to receive(:withdraw!)
      end

      it 'withdraws the paper' do
        expect(paper).to receive(:withdraw!).with(withdrawal_reason, user)
        do_request
      end

      it 'queues up an email that notifies the staff of paper withdrawal' do
        expect(UserMailer).to receive_message_chain(
          :delay,
          :notify_staff_of_paper_withdrawal
        ).with paper.id
        do_request
      end

      it 'creates an Activity' do
        expect(Activity).to receive(:paper_withdrawn!)
          .with(paper, user: user)
        do_request
      end

      it 'responds with the paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'responds with 200 OK' do
        do_request
        expect(response).to responds_with(200)
      end

      context 'when there is a transition error' do
        before do
          expect(Paper).to receive(:find_by_id_or_short_doi).and_return paper

          expect(paper).to receive(:withdraw!) do
            raise AASM::InvalidTransition.new(paper, "withdrawn", paper.publishing_state)
          end
        end

        it 'submission fails' do
          do_request
          expect(paper).to be_unsubmitted
        end

        it 'returns a 422 Unprocessible Entity error' do
          do_request
          expect(response.status).to eq(422)
          expect(response).to be_client_error
          expect(JSON[response.body]['errors'].first).to eq("Failure to transition to withdrawn")
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:withdraw, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
