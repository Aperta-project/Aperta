class TahiPlugin

  # Return all installed Tahi plugins.
  def self.plugins
    Bundler.load.specs.select { |gem| tahi_plugin?(gem) }
  end

  # Return true if the gem is a tahi plugin.
  def self.tahi_plugin?(gem)
    # TODO: In the future, only tahi- is allowed as a prefix
    gem.name =~ /\A(tahi_|tahi-|plos_|assess)/
  end
end
