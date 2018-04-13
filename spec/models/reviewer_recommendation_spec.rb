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

describe TahiStandardTasks::ReviewerRecommendation do
  describe "validations" do
    let(:recommendation) { FactoryGirl.build(:reviewer_recommendation) }

    it "is valid" do
      expect(recommendation.valid?).to be(true)
    end

    it "requires an :first_name" do
      recommendation.first_name = nil
      expect(recommendation.valid?).to be(false)
    end

    it "requires an :last_name" do
      recommendation.last_name = nil
      expect(recommendation.valid?).to be(false)
    end
    it "requires an :email" do
      recommendation.email = nil
      expect(recommendation.valid?).to be(false)
    end
  end

  describe "#paper" do
    let(:recommendation) { FactoryGirl.create(:reviewer_recommendation) }

    it "always proxies to paper" do
      expect(recommendation.paper).to eq(recommendation.reviewer_recommendations_task.paper)
    end
  end

  describe '#task' do
    let!(:task) { FactoryGirl.create(:reviewer_recommendations_task) }
    let!(:recommendation) do
      FactoryGirl.create(
        :reviewer_recommendation,
        reviewer_recommendations_task: task
      )
    end

    it 'always proxies to reviewer_recommendations_task' do
      expect(recommendation.task)
        .to eq(recommendation.reviewer_recommendations_task)
    end
  end
end
