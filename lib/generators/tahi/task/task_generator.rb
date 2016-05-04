module Tahi
  class TaskGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :name, type: :string, required: true
    argument :engine, type: :string, default: "tahi_standard_tasks"

    def generate
      @name = name.camelcase
      @task_title = camel_space(name).gsub(/\s*Task$/, "")
      @engine_path = find_engine_path(engine)
      @filename = name.underscore

      template_backend_model
      template_client_component
    end

    private

    def template_backend_model
      template_many(
        'model.rb',
        app_path('models', engine, "#{@filename}.rb"),

        'serializer.rb',
        app_path('serializers', engine, "#{@filename}_serializer.rb"),

        'model_spec.rb',
        spec_path('models', engine, "#{@filename}_spec.rb"),

        'serializer_spec.rb',
        spec_path('serializers', engine, "#{@filename}_serializer_spec.rb")
      )

      rake 'data:update_journal_task_types'
    end

    def template_client_component
      engine = "#{@engine_path} #{@engine.camelize} #{@engine.underscore}"
      ember_do "generate tahi-task #{name.underscore} #{engine}"
    end

    def ember_do(command)
      inside 'client' do
        run "./node_modules/.bin/ember #{command}"
      end
    end

    def app_path(*args)
      File.join @engine_path, './app', *args
    end

    def spec_path(*args)
      File.join @engine_path, './spec', *args
    end

    def template_many(*args)
      args.each_slice(2) do |slice|
        template slice[0], slice[1]
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

      unless source
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
