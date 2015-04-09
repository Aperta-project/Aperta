module Tahi
  class PluginGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    argument :path, type: :string, required: false

    def generate
      system("rails plugin new #{plugin_path} --full --mountable --skip-test-unit --skip-gemfile-entry")

      template 'index.js', File.join(client_path, 'index.js')
      template 'package.json', File.join(client_path, 'package.json')
    end

    private

    def client_path
      plugin_path + "/client"
    end

    def plugin_path
      path || Rails.root.join('engines', name.underscore)
    end

    def dasherized_module_name
      name.dasherize
    end
  end
end
