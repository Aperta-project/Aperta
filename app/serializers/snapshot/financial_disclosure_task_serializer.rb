class Snapshot::FinancialDisclosureTaskSerializer < Snapshot::BaseTaskSerializer
  def as_json
    funders = snapshot_funders
    if funders
        snapshot_nested_questions + funders
    else
      snapshot_nested_questions
    end
  end

  def snapshot_funders
    funders = []
    @task.funders.order(:id).each do |funder|
      funder_serializer = Snapshot::FunderSerializer.new funder
      funders << {name: "funder", type: "properties", children: funder_serializer.snapshot}
    end
    funders
  end
end
