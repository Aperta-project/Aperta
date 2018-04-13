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

describe NestedQuestionsController do
  let(:user) { create :user, :site_admin }

  before do
    sign_in user
  end

  describe "#index" do
    let!(:questions) { [question1, question2] }
    let!(:card) { FactoryGirl.create(:card, :versioned, journal: nil, name: "My Card") }
    let(:card_version) { card.latest_published_card_version }
    let(:root) { card.content_root_for_version(1) }
    let(:question1) { FactoryGirl.build(:card_content, card_version: card_version).tap { |c| root.children << c } }
    let(:question2) { FactoryGirl.build(:card_content, card_version: card_version).tap { |c| root.children << c } }

    def do_request(params = {})
      get(:index, { type: "My Card" }.merge(params), format: :json)
    end

    it "responds with a list of questions for the given :type" do
      do_request
      json = JSON.parse(response.body)
      expected_ids = questions.map(&:id).sort
      actual_ids = json.fetch("nested_questions", []).map { |hsh| hsh["id"] }.sort

      expect(actual_ids).to eq(expected_ids)
    end

    it "responds with 200 OK" do
      do_request
      expect(response.status).to eq(200)
    end

    it_behaves_like "when the user is not signed in"
  end
end
