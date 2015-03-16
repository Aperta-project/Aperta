module Tahi
  class PluginGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    argument :path, type: :string, required: false

    def generate
      plugin_dir = path || File.join(Rails.root, 'engines', name.underscore)

      system("rails plugin new #{plugin_dir} --full --mountable --skip-test-unit --skip-gemfile-entry")
      # might need to cleanup a few excess, non-used files

      client_dir = File.join(plugin_dir, 'client')
      template 'index.js',     File.join(client_dir, 'index.js')
      template 'package.json', File.join(client_dir, 'package.json')
    end

    private

    def dasherized_module_name
      name.dasherize
    end
  end
end
