module Tahi
  class TaskGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :plugin, type: :string, required: true

    def generate
      @task_name = camel_space(class_name) + " Task"
      @plugin_module = plugin.camelize

      engine_path = find_engine_path(plugin)
      app_dir = File.join(engine_path, 'app')

      template 'model.rb',      File.join(app_dir, 'models',      plugin, "#{name}_task.rb")
      template 'serializer.rb', File.join(app_dir, 'serializers', plugin, "#{name}_task_serializer.rb")
      template 'policy.rb',     File.join(app_dir, 'policies',    plugin, "#{name}_tasks_policy.rb")

      system "cd client && ember generate tahi-task #{name} #{engine_path}"

      Rake::Task['data:create_task_types'].invoke()
    end

    private

    # "CamelCase" -> "Camel Space"
    def camel_space(token)
      token.split(/(?=[A-Z])/).join(' ')
    end

    def find_engine_path(gem_name)
      # use path_sources to find only Gemfile entries installed via :path
      source = Bundler.definition.send(:sources).path_sources.detect do |s|
        s.name == gem_name
      end
      if !source
        fail Bundler::GemNotFound, "Could not find local gem '#{gem_name}' in "\
          " current bundle. Please ensure that it is a gem with a :path source."
      end
      source.path.to_s
    end
  end
end
