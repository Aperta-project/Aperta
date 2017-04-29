module Ithenticate
  # Adapter for document response from Ithenticate
  class ReportResponse < Response
    def success?
      @response_hash["api_status"] == 200
    end

    def report_url
      @response_hash["report_url"]
    end

    def score
      @response_hash["score"]
    end
  end
end
