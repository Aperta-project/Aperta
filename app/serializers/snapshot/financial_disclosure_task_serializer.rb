module Snapshot
  class FinancialDisclosureTaskSerializer < BaseTaskSerializer

    def snapshot
      {
        funders: snapshot_funders,
        questions: snapshot_nested_questions
      }
    end

    def snapshot_funders
      funders = []
      @task.funders.order(:id).each do |funder|
        funder_serializer = Snapshot::FunderSerializer.new funder
        funders << { funder: funder_serializer.snapshot }
      end
      funders
    end
  end
end
