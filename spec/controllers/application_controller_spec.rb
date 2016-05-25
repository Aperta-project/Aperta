require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      redirect_to "/"
    end
  end

  describe "#cas_logout_path" do
    let(:controller) do
      ApplicationController.new.tap do |c|
        allow(c).to receive(:new_user_session_url).and_return login_url
      end
    end
    let(:login_url) { 'http://example.com/user/login' }

    it "returns CAS's logout resource" do
      logout_url = Rails.configuration.x.cas['logout_full_url']
      url = controller.send(:cas_logout_url)
      expect(url).to be_a_valid_url
      expect(url).to include logout_url
      expect(url).to include CGI.escape(login_url)
    end
  end
end
