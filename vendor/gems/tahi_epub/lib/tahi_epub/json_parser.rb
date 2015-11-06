require 'json'

module TahiEpub
  module JSONParser
    def self.parse(json)
      JSON.parse json, symbolize_names: true
    end
  end
end
