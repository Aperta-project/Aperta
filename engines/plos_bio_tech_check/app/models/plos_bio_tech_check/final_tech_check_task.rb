module PlosBioTechCheck
  class FinalTechCheckTask < Task
    DEFAULT_TITLE = 'Final Tech Check'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    before_create :initialize_body
    before_save   :sanitize_html

    def self.nested_questions
      NestedQuestion.where(owner_id: nil, owner_type: name).all
    end

    def active_model_serializer
      FinalTechCheckTaskSerializer
    end

    def letter_text
      body["finalTechCheckBody"]
    end

    def letter_text=(text)
      self.body = body.merge("finalTechCheckBody" => text)
    end

    private

    def initialize_body
      self.body = {}
    end

    def sanitize_html
      body["finalTechCheckBody"] =
        HtmlScrubber.standalone_scrub!(body["finalTechCheckBody"],
                                       "html-expanded")
    end
  end
end
