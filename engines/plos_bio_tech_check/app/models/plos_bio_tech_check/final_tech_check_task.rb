module PlosBioTechCheck
  class FinalTechCheckTask < Task
    DEFAULT_TITLE = 'Final Tech Check'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    before_create :initialize_body

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
