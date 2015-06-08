require 'rails_helper'

describe "routes for users" do
  it "routes /api/roles/:id/users to the index action in users controller" do
    expect({ get: '/api/roles/:id/users', format: :json }).to route_to(
      controller: "roles/users", action: "index", role_id: ":id"
    )
  end
end
