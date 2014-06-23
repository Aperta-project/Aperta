require 'spec_helper'

describe QuestionsPolicy do
  let(:policy) { QuestionsPolicy.new(current_user: user, question: question) }
  let(:question) { FactoryGirl.create(:question, task: task) }
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let(:task) { paper.phases.first.tasks.first }

  context "A super admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.create?).to eq(true) }
    it { expect(policy.update?).to eq(true) }
  end

  context "An author" do
    let(:user) { paper.user }

    it { expect(policy.create?).to eq(true) }
    it { expect(policy.update?).to eq(true) }
  end

  context "some schmuck" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.create?).to eq(false) }
    it { expect(policy.update?).to eq(false) }
  end
end
