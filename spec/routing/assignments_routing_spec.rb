require 'rails_helper'

describe "routes for assignments" do
  it "routes /api/assignments to the index action in assignments controller" do
    expect({ get: '/api/assignments', format: :json }).to route_to controller: "assignments",
      action: "index"
  end

  it "routes /api/assignments to the create action in assignments controller" do
    expect({ post: '/api/assignments', format: :json }).to route_to controller: "assignments",
      action: "create"
  end
end
