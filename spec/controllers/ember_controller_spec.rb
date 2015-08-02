require 'rails_helper'

describe EmberController do
  describe "#store_location" do
    it "stores location" do
      get :index
      expect(session[:user_return_to]).to_not be_blank
    end
  end
end
