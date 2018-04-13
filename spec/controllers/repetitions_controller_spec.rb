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
        expect(repetition_a.reload.position).to eq(1)
        expect(repetition_b.reload.position).to eq(2)
        expect(repetition_c.reload.position).to eq(0)
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
    let!(:another_repetition) { FactoryGirl.create(:repetition, task: task, card_content: card_content) }
    let(:destroying_all) { true }

    subject(:do_request) do
      delete :destroy,
            format: "json",
            id: repetition.id,
            destroying_all: destroying_all,
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

      context "when destroying one" do
        let(:destroying_all) { false }

        it "destroys a repetition" do
          expect { do_request }.to change(Repetition, :count).by(-1)
        end

        it "does not return itself" do
          do_request
          repetitions = res_body["repetitions"]
          expect(repetitions.length).to eq(1)
          expect(repetitions.first["id"]).to eq(another_repetition.id)
        end

        it { is_expected.to responds_with(200) }
      end

      context "when destroying all" do
        let(:destroying_all) { true }

        it "destroys a repetition" do
          expect { do_request }.to change(Repetition, :count).by(-1)
        end

        it { is_expected.to responds_with(204) }
      end
    end

    context "when the user does not have access" do
      let(:destroying_all) { false }

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
