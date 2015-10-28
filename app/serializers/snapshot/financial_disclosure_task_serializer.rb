class Snapshot::FinancialDisclosureTaskSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    model.funders.order(:id).map do |funder|
      Snapshot::FunderSerializer.new(funder).as_json
    end
  end
end
