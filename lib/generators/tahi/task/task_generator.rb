module Tahi
  class TaskGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :plugin, type: :string, required: true

    def generate
      app_dir = File.join(engine_path, 'app')
      template 'model.rb', File.join(app_dir, 'models', plugin, "#{name}_task.rb")
      template 'serializer.rb', File.join(app_dir, 'serializers', plugin, "#{name}_task_serializer.rb")
      template 'policy.rb', File.join(app_dir, 'policies', plugin, "#{name}_tasks_policy.rb")
      system("cd client && ember generate tahi-task #{name} #{engine_path}")
      print_wrapped "New task #{name} generated in #{engine_path}."
      print_wrapped "Now run `rake data:create_task_types`"
    end

    private

    def engine_path
      @engine_path ||= begin
        spec = Bundler.load.specs.find { |s| s.name == plugin }
        fail Exception, "Could not find gem '#{plugin}' in the current bundle." unless spec
        spec.full_gem_path
      end
    end
  end
end
