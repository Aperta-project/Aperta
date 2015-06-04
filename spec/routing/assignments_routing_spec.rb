require 'rails_helper'

describe "routes for assignments" do
  it "routes /papers/:id/assignments to the index action in assignments controller" do
    expect({ get: '/api/papers/786/assignments', format: :json }).to route_to controller: "assignments",
                                                                              action: "index",
                                                                              paper_id: "786"
  end
end
