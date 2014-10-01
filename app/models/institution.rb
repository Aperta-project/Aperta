require 'singleton'

class Institution
  include Singleton

  def names_hash
    @names_hash ||= names.map { |name| { name: name } }
  end

  def names
    @names ||= institutions.map { |institution| institution['name'] }
  end

  def institutions
    @hash ||= YAML.load File.read Rails.root.join('config/institutions.yml')
  end
end
