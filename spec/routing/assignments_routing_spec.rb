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

  it "routes /api/assignments/1 to the destroy action in assignments controller" do
    expect({ delete: '/api/assignments/:id', format: :json }).to route_to controller: "assignments",
      action: "destroy", id: ":id"
  end
end
