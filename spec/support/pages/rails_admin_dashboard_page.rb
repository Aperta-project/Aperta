class RailsAdminDashboardPage < Page
  path :rails_admin

  def initialize(*args)
    super
    synchronize_content! "Site Administration"
  end

  def navigate_to(model_name)
    within(all('ul.nav.nav-list').first) do
      click_on model_name
    end

    model_class = model_name.gsub(/\s/, '_').camelize
    "Admin#{model_class}Page".constantize.new
  end
end
