class SignUpPage < Page
  def self.visit
    self.new.tap { |p| p.navigate }
  end

  def navigate
    visit new_user_registration_path
    expect(page.current_path).to eq new_user_registration_path
  end

  def sign_up_as options
    fill_in "First name", with: options.fetch(:first_name)
    fill_in "Last name", with: options.fetch(:last_name)
    fill_in "Email", with: options.fetch(:email)
    fill_in "Password", with: options.fetch(:password)
    fill_in "Password confirmation", with: options.fetch(:password)
    fill_in "Affiliation", with: options.fetch(:affiliation)
    click_on "Sign up"

    DashboardPage.new
  end
end
