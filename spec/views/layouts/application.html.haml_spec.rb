require 'spec_helper'
describe "layouts/application" do
  before { allow(view).to receive(:current_user).and_return(current_user) }

  let(:admin) { false }
  let(:current_user) { mock_model User, admin?: admin, full_name: "Batman", image_url: "none" }

  subject { render; Capybara.string(rendered) }

  it { should_not have_link 'Admin' }
  it { should have_link 'Sign out' }

  context "when the user is not signed in" do
    let(:current_user) { nil }
    it { should_not have_link 'Sign out' }
  end

  context "when the user is an admin" do
    let(:admin) { true }
    it { should have_link 'Admin' }
  end
end
