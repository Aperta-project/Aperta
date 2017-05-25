module Ithenticate
  # Generic adapter for responses from Ithenticate
  class Response
    attr_accessor :response_hash

    def initialize(response_hash)
      @response_hash = response_hash
    end
  end
end
