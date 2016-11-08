module PlosBioTechCheck
  class FinalTechCheckTask < Task
    DEFAULT_TITLE = 'Final Tech Check'
    DEFAULT_ROLE = 'editor'

    before_create :initialize_body

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
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
  end
end
