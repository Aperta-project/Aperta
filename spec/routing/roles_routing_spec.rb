require 'rails_helper'

describe "routes for old_roles" do
  it "routes /old_roles to the index action in old_roles controller" do
    expect(get: '/api/journals/:id/old_roles', format: :json).to route_to(
      ember_app: :tahi,
      controller: 'ember_cli/ember',
      action: 'index',
      rest: 'api/journals/:id/old_roles'
    )
  end
end
