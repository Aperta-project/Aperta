require 'rails_helper'

describe RepetitionsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "#index" do
    let(:repetition) { FactoryGirl.create(:repetition) }
    let(:task) { repetition.task }

    subject(:do_request) do
      get :index, format: "json",
                  repetition: { task_id: task.id }
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
        expect(res_body['repetitions'].first['id']).to eq(task.id)
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
              parent_id: parent_repetition.id
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
