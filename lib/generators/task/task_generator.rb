class TaskGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :task_name, type: :string
  attr_accessor :engine_name, :path_name

  def get_user_info
    @engine_name = ARGV.first
    puts "You have specified an Engine name of: \"#{@engine_name}\""
    puts "By default, your Engine will be created in the folder \"#{default_path}\""
    @path_name = ask("Would you like to create your Engine in a different folder? If so, specify the folder name here. (defaults to #{Rails.root}/#{default_engine_dir})")
    @path_name = @path_name.present? ? @path_name : default_engine_dir
    create_engine_task
  end

  def generate_files
    template "model.rb",            "#{new_path}/app/models/#{engine_file_name}/#{file_name}_task.rb"
    template "subscriptions.rb",    "#{new_path}/app/models/subscriptions.rb"
    template "serializer.rb",       "#{new_path}/app/serializers/#{engine_file_name}/#{file_name}_task_serializer.rb"
    template "policy.rb",           "#{new_path}/app/policies/#{engine_file_name}/#{file_name}_tasks_policy.rb"
    template "ember/model.js",      "#{new_path}/app/assets/javascripts/#{engine_file_name}/models/#{file_name}_task.js"
    template "ember/view.js",       "#{new_path}/app/assets/javascripts/#{engine_file_name}/views/overlays/#{file_name}_overlay_view.js"
    template "ember/controller.js", "#{new_path}/app/assets/javascripts/#{engine_file_name}/controllers/overlays/#{file_name}_overlay_controller.js"
    template "ember/serializer.js", "#{new_path}/app/assets/javascripts/#{engine_file_name}/serializers/#{file_name}_task_serializer.js"
    template "ember/adapter.js",    "#{new_path}/app/assets/javascripts/#{engine_file_name}/adapters/#{file_name}_task_adapter.js"
    template "ember/overlay.hbs",   "#{new_path}/app/assets/javascripts/#{engine_file_name}/templates/overlays/#{file_name}_overlay.hbs"
  end


  private

  def default_engine_dir
    'engines/'
  end

  def default_path
    File.join default_engine_dir, engine_file_name
  end

  def file_name
    @task_name.underscore
  end

  def class_name
    @task_name.camelize
  end

  def engine_file_name
    @engine_name.underscore
  end

  def engine_class_name
    @engine_name.camelize
  end

  def new_path
    File.join(path_name, engine_file_name)
  end

  def engine_exists?(engine)
    File.directory?("engines/#{engine}")
  end

  def path_exists?(path)
    File.directory?(path)
  end

  def create_engine_task
    return if path_exists?(default_path) ||
              path_exists?(new_path)

    cmd = "rails plugin new #{new_path} --full --mountable --skip-test-unit"
    puts cmd
    system cmd
  end
end
