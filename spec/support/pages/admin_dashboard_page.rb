class AdminDashboardPage < Page
  path :rails_admin

  def navigate_to model_name
    within(all('ul.nav.nav-list').first) do
      click_on model_name
    end
    "Admin#{model_name}Page".constantize.new
  end
end
