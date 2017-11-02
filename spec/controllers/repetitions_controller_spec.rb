require 'rails_helper'

describe RepetitionsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "#index" do
    let(:repetition) { FactoryGirl.create(:repetition) }
    let(:task) { repetition.task }

    subject(:do_request) do
      get :index, format: "json", task_id: task.id
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return(true)
      end

      it "returns repetitions for task" do
        do_request
        expect(res_body['repetitions'].size).to eq(1)
        expect(res_body['repetitions'].first['id']).to eq(repetition.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#create" do
    let(:task) { FactoryGirl.create(:custom_card_task, :with_card) }
    let(:card_content) { task.card_version.card_contents.first }
    let!(:parent_repetition) { FactoryGirl.create(:repetition, task: task, card_content: card_content) }

    subject(:do_request) do
      post :create,
            format: 'json',
            repetition: {
              card_content_id: card_content.id,
              task_id: task.id,
              parent_id: parent_repetition.id,
              position: 0
            }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return(true)
      end

      it "creates a repetition" do
        expect { do_request }.to change(Repetition, :count).by(1)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#update" do
    let(:task) { FactoryGirl.create(:custom_card_task, :with_card) }
    let(:card_content) { task.card_version.card_contents.first }
    let!(:repetition_a) { FactoryGirl.create(:repetition, task: task, card_content: card_content, position: 0) }
    let!(:repetition_b) { FactoryGirl.create(:repetition, task: task, card_content: card_content, position: 1) }
    let!(:repetition_c) { FactoryGirl.create(:repetition, task: task, card_content: card_content, position: 2) }

    subject(:do_request) do
      put :update,
            format: 'json',
            id: repetition_c.id,
            repetition: {
              card_content_id: card_content.id,
              task_id: task.id,
              position: 0
            }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return(true)
      end

      it "updates a repetition position (along with siblings)" do
        do_request
        expect(repetition_a.reload.position).to be(1)
        expect(repetition_b.reload.position).to be(2)
        expect(repetition_c.reload.position).to be(0)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#destroy" do
    let(:task) { FactoryGirl.create(:custom_card_task, :with_card) }
    let(:card_content) { task.card_version.card_contents.first }
    let!(:repetition) { FactoryGirl.create(:repetition, task: task, card_content: card_content) }

    subject(:do_request) do
      delete :destroy,
            format: "json",
            id: repetition.id,
            repetition: {
              task_id: task.id
            }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return(true)
      end

      it "creates a repetition" do
        expect { do_request }.to change(Repetition, :count).by(-1)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
