class EmberAddonsInstaller
  attr_reader :package_path

  def initialize
    @package_path = File.join Rails.root, 'client', 'package.json'
  end

  def add_addons_from_gems
    new_package = append_addon_paths_to_package
    File.open(package_path, 'w') << JSON.pretty_generate(new_package)
  end

  private

  def append_addon_paths_to_package
    package = load_package_as_json
    package['ember-addon'] ||= {}
    addon_paths = package['ember-addon']['paths'] ||= []

    tahi_gem_paths.each do |tahi_gem_path|
      unless addon_paths.find { |path| path == tahi_gem_path }
        package['ember-addon']['paths'].push tahi_gem_path
      end
    end
    package
  end

  def tahi_gem_paths
    # Bundler.load.specs.select { |gem| gem.name =~ /\Atahi-/ }
    Bundler.load.specs.select { |gem| gem.name =~ /\Aplos/ }
                      .map { |gem| "#{gem.full_gem_path}/client" }
  end

  def load_package_as_json
    JSON.load File.open(package_path)
  end
end

EmberAddonsInstaller.new.add_addons_from_gems
