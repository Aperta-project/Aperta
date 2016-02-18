require 'rails_helper'

describe "routes for users" do
  it "routes /api/old_roles/:id/users to the index action in users controller" do
    expect(get: '/api/old_roles/:id/users', format: :json).to route_to(
      ember_app: :tahi,
      controller: 'ember_cli/ember',
      action: 'index',
      rest: 'api/old_roles/:id/users'
    )
  end
end
