module PlosBioTechCheck
  class RevisionTechCheckTask < Task
    DEFAULT_TITLE = 'Revision Tech Check'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    before_create :initialize_body
    before_save   :sanitize_html

    def self.nested_questions
      NestedQuestion.where(owner_id: nil, owner_type: name).all
    end

    def active_model_serializer
      RevisionTechCheckTaskSerializer
    end

    def letter_text
      body["revisedTechCheckBody"]
    end

    def letter_text=(text)
      self.body = body.merge("revisedTechCheckBody" => text)
    end

    private

    def initialize_body
      self.body = {}
    end

    def sanitize_html
      body["revisedTechCheckBody"] =
        HtmlScrubber.standalone_scrub!(body["revisedTechCheckBody"],
                                         "html-expanded")
    end
  end
end
