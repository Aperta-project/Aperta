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

describe AnswersController do
  let(:user) { FactoryGirl.create :user }
  let(:card_content) { FactoryGirl.create(:card_content) }
  let(:owner) { FactoryGirl.create(:ad_hoc_task) }

  describe "#create" do
    subject(:do_request) do
      post_params = {
        format: 'json',
        answer: {
          value: "Hello",
          annotation: "World",
          owner_id: owner.id,
          owner_type: owner.class.name,
          card_content_id: card_content.id
        }
      }
      post(:create, post_params)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:edit, owner)
                         .and_return true
      end

      it "creates an answer for the question" do
        expect do
          do_request
        end.to change(Answer, :count).by(1)

        answer = Answer.last
        expect(answer.card_content).to eq(card_content)
        expect(answer.owner).to eq(owner)
        expect(answer.value).to eq("Hello")
        expect(answer.annotation).to eq("World")
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(201)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:edit, owner)
                         .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#update" do
    let!(:answer) { FactoryGirl.create(:answer, value: 'initial value', annotation: "iniitial annotation", card_content: card_content, owner: owner) }

    subject(:do_request) do
      put_params = {
        format: 'json',
        id: answer.to_param,
        card_content_id: card_content.to_param,
        answer: {
          value: 'updated value',
          annotation: 'updated annotation'
        }
      }
      put(:update, put_params)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:edit, owner)
                         .and_return true
      end

      context 'updates the answer for the question' do
        it 'updates the answer for the question' do
          expect do
            do_request
          end.to_not change(Answer, :count)

          json = JSON.parse(response.body)
          expect(json['answer']['value']).to_not be_present
          expect(json['answer']['annotaion']).to_not be_present
          answer.reload
          expect(answer.annotation).to eq('updated annotation')
        end
      end

      it "returns 200" do
        do_request
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['answer']).to be_present
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:edit, owner)
                         .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#destroy" do
    let!(:answer) { FactoryGirl.create(:answer, value: "Hi", annotation: "there", owner: owner) }
    let(:card_content) { FactoryGirl.create(:card_content) }

    subject(:do_request) do
      delete_params = {
        format: 'json',
        id: answer.to_param
      }
      delete(:destroy, delete_params)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user does has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:edit, owner)
                         .and_return true
      end

      it "deletes the answer for the question" do
        expect do
          do_request
        end.to change(Answer, :count).by(-1)
      end

      it "responds with 204" do
        do_request
        expect(response.status).to eq(204)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:edit, owner)
                         .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
