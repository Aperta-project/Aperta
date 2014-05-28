# RailsAdmin config file. Generated on December 12, 2013 13:26
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|
  config.authorize_with do
    redirect_to main_app.root_path unless warden.user.admin?
  end

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Tahi', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Include specific models (exclude the others):
  config.included_models = ['UserRole', 'User', 'Journal', 'Role']


  config.model 'Journal' do

    edit do
      exclude_fields :users
    end
  end


  config.model 'Role' do

    object_label_method :label

    list do
      field :journal
      field :name
      sort_by :journal, :name
    end
  end


  config.model 'User' do

    object_label_method :full_name

    edit do
      exclude_fields :journals
    end

  end

end
