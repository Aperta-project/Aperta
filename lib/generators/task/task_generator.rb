class TaskGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :task_name, type: :string
  attr_accessor :engine_name

  def get_user_info
    @engine_name = ask('What engine would you like to create? (To add to an existing engine, use the folder name, e.g. "standard_tasks")')
    raise 'Please specify the folder to place your new Task within' unless @engine_name.present?
    standalone_task_with_engine(engine_name)
  end

  def generate_files
    template "model.rb",            "engines/#{engine_file_name}/app/models/#{engine_file_name}/#{file_name}_task.rb"
    template "serializer.rb",       "engines/#{engine_file_name}/app/serializers/#{engine_file_name}/#{file_name}_task_serializer.rb"
    template "ember/model.js",      "engines/#{engine_file_name}/app/assets/javascripts/#{engine_file_name}/models/#{file_name}_task.js"
    template "ember/view.js",       "engines/#{engine_file_name}/app/assets/javascripts/#{engine_file_name}/views/overlays/#{file_name}_overlay_view.js"
    template "ember/controller.js", "engines/#{engine_file_name}/app/assets/javascripts/#{engine_file_name}/controllers/overlays/#{file_name}_overlay_controller.js"
    template "ember/serializer.js", "engines/#{engine_file_name}/app/assets/javascripts/#{engine_file_name}/serializers/#{file_name}_task_serializer.js"
    template "ember/adapter.js",    "engines/#{engine_file_name}/app/assets/javascripts/#{engine_file_name}/adapters/#{file_name}_task_adapter.js"
    template "ember/overlay.hbs",   "engines/#{engine_file_name}/app/assets/javascripts/#{engine_file_name}/templates/overlays/#{file_name}_overlay.hbs"
  end

  def append_files
    inject_into_file "app/services/task_services/create_task_types.rb", before: "]" do
      "{kind: '#{engine_class_name}::#{class_name}Task', default_role: 'author', default_title: '#{class_name}'},\n"
    end
  end

  private

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

  def standalone_task_with_engine(engine)
    return if engine_exists?(engine)
    cmd = "rails plugin new engines/#{engine} --full —mountable —skip-test-unit"
    puts cmd
    system cmd
  end

  def engine_exists?(engine)
    File.directory?("engines/#{engine}")
  end
end
