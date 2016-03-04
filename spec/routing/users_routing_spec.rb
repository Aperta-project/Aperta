require 'rails_helper'

describe "routes for users" do
  it "routes /api/old_roles/:id/users to the index action in users controller" do
    expect({ get: '/api/old_roles/:id/users', format: :json }).to route_to(
      controller: "old_roles/users", action: "index", old_role_id: ":id"
    )
  end
end
