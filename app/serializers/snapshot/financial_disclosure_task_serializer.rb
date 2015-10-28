class Snapshot::FinancialDisclosureTaskSerializer < Snapshot::BaseTaskSerializer

  private

  def snapshot_properties
    snapshot_funders
  end

  def snapshot_funders
    @task.funders.order(:id).map do |funder|
      Snapshot::FunderSerializer.new(funder).as_json
    end
  end
end
