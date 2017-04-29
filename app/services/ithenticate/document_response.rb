module Ithenticate
  # Adapter for document response from Ithenticate
  class DocumentResponse < Response
    def report_id
      return @report_id if @report_id
      document = @response_hash["documents"].try(:first)
      return unless document
      part = document["parts"].try(:first)
      return unless part
      @report_id = part["id"]
    end

    def report_complete?
      report_id.present?
    end
  end
end
