class Snapshot::FinancialDisclosureTaskSerializer < Snapshot::BaseTaskSerializer
  def snapshot
    funders = snapshot_funders
    if funders
        funders + snapshot_nested_questions
    else
      snapshot_nested_questions
    end
  end

  def snapshot_funders
    funders = []
    @task.funders.order(:id).each do |funder|
      funder_serializer = Snapshot::FunderSerializer.new funder
      funders << {name: funder, type: "properties", children: funder_serializer.snapshot}
    end
    funders
  end
end
