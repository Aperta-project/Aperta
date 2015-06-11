require 'rails_helper'

describe "routes for roles" do
  it "routes /roles to the index action in roles controller" do
    expect({ get: '/api/journals/:id/roles', format: :json }).to route_to(
      controller: "roles", action: "index", journal_id: ":id"
    )
  end
end
