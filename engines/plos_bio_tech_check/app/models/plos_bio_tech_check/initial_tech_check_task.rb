module PlosBioTechCheck
  class InitialTechCheckTask < Task
    include NotifyAuthorOfChanges

    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    DEFAULT_TITLE = 'Initial Tech Check'
    DEFAULT_ROLE = 'editor'

    before_create :initialize_round

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def active_model_serializer
      PlosBioTechCheck::InitialTechCheckTaskSerializer
    end

    def increment_round!
      body['round'] = round.next
      save!
    end

    def letter_text
      body["initialTechCheckBody"]
    end

    def letter_text=(text)
      self.body = body.merge("initialTechCheckBody" => text)
    end

    def round
      body['round'] || 1
    end

    private

    def initialize_round
      self.body = { round: 1 }
    end
  end
end
