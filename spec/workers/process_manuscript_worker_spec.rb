require 'rails_helper'

describe ProcessManuscriptWorker do
  subject(:worker) { described_class.new }

  describe "#perform" do
    it "does not retry" do
      expect(worker.sidekiq_options_hash["retry"]).to be(false)
    end
  end
end
