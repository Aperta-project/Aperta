require 'rails_helper'

describe PaperUnlockerWorker, redis: true do
  let(:paper) { FactoryGirl.create(:paper, locked_by_id: 99) }

  describe "#perform" do

    it "will unlock paper" do
      Sidekiq::Testing.disable! do
        PaperUnlockerWorker.new.perform(paper.id)
        expect(paper.reload).to be_unlocked
      end
    end

  end

  describe "#perform" do
    before { Sidekiq::ScheduledSet.new.clear }
    after  { Sidekiq::ScheduledSet.new.clear }

    it "will leave paper locked" do
      Sidekiq::Testing.disable! do
        PaperUnlockerWorker.new.perform(paper.id, true)
        expect(paper.reload).to be_locked
      end
    end

    it "will enqueue a future unlock" do
      Sidekiq::Testing.disable! do
        expect {
          PaperUnlockerWorker.new.perform(paper.id, true)
        }.to change {
          Sidekiq::ScheduledSet.new.size
        }.by(1)
      end
    end
  end
end
