require 'rails_helper'

RSpec.describe ScheduledEventsController, type: :controller do

  describe "GET #active" do
    it "returns http success" do
      get :active
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #passive" do
    it "returns http success" do
      get :passive
      expect(response).to have_http_status(:success)
    end
  end

end
