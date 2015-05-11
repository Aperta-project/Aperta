module Tahi
  class TaskGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :plugin, type: :string, required: true

    def generate
      fail Exception, "Plugins must be prefixed with 'tahi'." unless plugin.match(/^tahi-/)
      @plugin_short = plugin.gsub(/^tahi-/, '')
      @task_name = (class_name.split(/(?=[A-Z])/) + ['Task']).join(' ')
      template 'model.rb', File.join(app_dir, 'models', 'tahi', @plugin_short, "#{name}_task.rb")
      template 'serializer.rb', File.join(app_dir, 'serializers', 'tahi', @plugin_short, "#{name}_task_serializer.rb")
      template 'policy.rb', File.join(app_dir, 'policies', 'tahi', @plugin_short, "#{name}_tasks_policy.rb")
      system("cd client && ember generate tahi-task #{name} #{engine_path}")
      print_wrapped "New task #{name} generated in #{engine_path}."
      print_wrapped "Now run `rake data:create_task_types`"
    end

    private

    def app_dir
      File.join(engine_path, 'app')
    end

    def engine_path
      @engine_path ||= begin
                         spec = Bundler.load.specs.detect { |s| s.name == plugin }
                         fail Exception, "Could not find gem '#{plugin}' in the current bundle." unless spec
                         spec.full_gem_path
                       end
    end
  end
end
