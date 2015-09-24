module Snapshot
  class CompetingInterestTaskSerializer < BaseSerializer
    attr_reader :task

    def initialize(task:)
      @task = task
    end

    def snapshot
      
    end
  end
end
