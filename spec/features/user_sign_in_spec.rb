require 'spec_helper'

feature "Account creation" do

  before do
    clear_emails!
  end

  def clear_emails!
    ActionMailer::Base.deliveries.clear
  end

  def find_email recipient, subject
    ActionMailer::Base.deliveries.detect do |email|
      email.to.include?(recipient) && email.subject == subject
    end
  end

  def find_url(email)
    email.body.to_s.scan(/<a.+?href="(.+?)".+?/).first.first
  end

  scenario "User can create an account" do
    sign_up_page = SignUpPage.visit
    dashboard_page = sign_up_page.sign_up_as first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      affiliation: 'Universität Zürich'
    email = find_email 'einstein@example.org', "Confirmation instructions"
    confirmation_url = find_url email
    visit confirmation_url

    sign_in_page = SignInPage.new
    sign_in_page.sign_in_as(User.last)
    expect(page.current_path).to eq(root_path)
    expect(dashboard_page.header).to have_content 'Welcome, Albert Einstein'
  end
end

feature "Signing in" do
  scenario "User can sign in to the site" do
    user = User.create! first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
    user.confirm!

    sign_in_page = SignInPage.new
    sign_in_page.sign_in_as(user)
    expect(page.current_path).to eq(root_path)
  end
end
