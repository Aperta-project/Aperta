require 'singleton'

class Institutions < NedConnection
  include Singleton

  def matching_institutions(query)
    if TahiEnv.ned_enabled?
      search('institutionsearch', substring: query).body
    else
      search_predefined query
    end
  end

  private

  def predefined_institutions
    @institutions ||= YAML.load File.read Rails.root.join('config/institutions2.yml')
  end

  def search_predefined(query)
    predefined_institutions.select { |i| i['name'].downcase.match(query.downcase) }
  end
end
