module Ithenticate
  # Adapter for document response from Ithenticate
  class DocumentResponse < Response
    def first_document
      @response_hash["documents"].try(:first)
    end

    def first_part
      return unless first_document
      first_document["parts"].try(:first)
    end

    def report_complete?
      report_id.present?
    end

    def report_id
      return unless first_part
      first_part["id"]
    end

    def score
      return unless first_part
      first_part["score"]
    end
  end
end
