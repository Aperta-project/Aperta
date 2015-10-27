require "rails_helper"

describe Snapshot::DataAvailabilityTaskSerializer do
  let(:data_availability_task) { FactoryGirl.create(:data_availability_task)}

  it "serializes a data availability task" do
    snapshot = Snapshot::DataAvailabilityTaskSerializer.new(data_availability_task).as_json

    expect(snapshot[0][:name]).to eq("data_fully_available")
    expect(snapshot[1][:name]).to eq("data_location")
  end
end
