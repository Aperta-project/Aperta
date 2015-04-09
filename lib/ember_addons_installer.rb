require 'json'
class EmberAddonsInstaller
  attr_reader :package_path
  attr_accessor :package

  def initialize(package_path: Rails.root.join('client', 'package.json'))
    @package_path = package_path
    @package = load_package_as_json
  end

  def add_addons_from_gems
    new_package = append_addon_paths_to_package
    File.open package_path, 'w' do |file|
      file << JSON.pretty_generate(new_package)
    end
  end

  private

  def append_addon_paths_to_package
    package['ember-addon'] ||= {}
    addon_paths = package['ember-addon']['paths'] ||= []

    TahiPlugin.plugins.
      map { |gem| relative_path_from_root "#{gem.full_gem_path}/client" }.
      each do |tahi_gem_path|
      unless addon_paths.find { |path| path == tahi_gem_path }
        package['ember-addon']['paths'].push tahi_gem_path
      end
    end
    remove_missing_addons
    package
  end

  def relative_path_from_root full_gem_path
    Pathname.new(full_gem_path)
            .relative_path_from(Pathname.new "#{Rails.root}/client")
            .to_s
  end

  def remove_missing_addons
    package["ember-addon"]["paths"].reject! { |path|
      !File.directory?(File.join(Rails.root, 'client', path))
    }
  end

  def load_package_as_json
    JSON.load File.open(package_path)
  end
end
