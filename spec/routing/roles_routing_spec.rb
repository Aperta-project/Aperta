require 'rails_helper'

describe "routes for old_roles" do
  it "routes /old_roles to the index action in old_roles controller" do
    expect({ get: '/api/journals/:id/old_roles', format: :json }).to route_to(
      controller: "old_roles", action: "index", journal_id: ":id"
    )
  end
end
