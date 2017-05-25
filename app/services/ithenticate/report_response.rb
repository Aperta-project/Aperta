module Ithenticate
  # Adapter for document response from Ithenticate
  class ReportResponse < Response
    def success?
      @response_hash["api_status"] == 200
    end

    def report_url
      @response_hash["report_url"]
    end

    def view_only_url
      @response_hash["view_only_url"]
    end
  end
end
