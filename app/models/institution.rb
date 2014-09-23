require 'singleton'

class Institution
  include Singleton

  def names
    @names ||= institutions.map { |institution| { name: institution['name'] } }
  end

  def institutions
    @hash ||= YAML.load File.read Rails.root.join('config/institutions.yml')
  end
end
