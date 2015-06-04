module Tahi

  # These plugins are excluded from the 'tahi-' prefix requirement,
  # and will be removed from the array as they are updated.
  LEGACY_PLUGINS = [
    'tahi_standard_tasks',
    'tahi_upload_manuscript',
    'plos_authors',
    'plos_billing',
    'plos_bio_tech_check'
  ]

  class TaskGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :plugin, type: :string, required: true

    def generate
      name_check plugin

      @task_name = camel_space(class_name) + " Task"
      @plugin_module = plugin.camelize

      engine_path = find_engine_path(plugin)

      template 'model.rb',      File.join(engine_path, 'app', 'models',      plugin, "#{name}_task.rb")
      template 'serializer.rb', File.join(engine_path, 'app', 'serializers', plugin, "#{name}_task_serializer.rb")
      template 'policy.rb',     File.join(engine_path, 'app', 'policies',    plugin, "#{name}_tasks_policy.rb")

      inside 'client' do
        run "ember generate tahi-task #{name} ../#{engine_path}"
      end

      rake 'data:create_task_types'
    end

    private

    def name_check(plugin)
      if LEGACY_PLUGINS.include? plugin
        puts 'Skipping prefix check for legacy plugin'
      elsif !plugin.match /^tahi-/
        die "Plugins must be prefixed with 'tahi-'."
      end
    end

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
        die "Could not find local gem '#{gem_name}' in current bundle. Please"\
            " ensure that it is a gem with a :path source."
      end
      Pathname.new(source.path.to_s).expand_path
    end

    def die(msg)
      puts "\033[31m#{msg}\033[0m"
      exit 1
    end
  end

end
