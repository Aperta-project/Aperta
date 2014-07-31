require 'singleton'

class InstitutionHashParser
  include Singleton
  attr_reader :names

  def parse_names!
    @names ||= affiliations.map { |institution| institution['name'] }
  end

  def affiliations
    @hash ||= YAML.load File.read Rails.root.join("config/institutions.yml")
  end
end
