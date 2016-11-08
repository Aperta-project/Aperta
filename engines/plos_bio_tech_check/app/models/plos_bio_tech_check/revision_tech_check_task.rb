module PlosBioTechCheck
  class RevisionTechCheckTask < Task
    DEFAULT_TITLE = 'Revision Tech Check'
    DEFAULT_ROLE = 'editor'

    before_create :initialize_body

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
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
  end
end
