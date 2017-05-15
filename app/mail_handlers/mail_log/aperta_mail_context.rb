module MailLog
  # ApertaMailContext is used to store a hash of contextual information
  # for a particular email being set.
  class ApertaMailContext
    attr_reader :model_hash

    def initialize(context_hash)
      @context_hash = context_hash
      @model_hash = @context_hash.select do |key, value|
        value.is_a?(ActiveRecord::Base)
      end
      @task = @model_hash.values.detect { |value| value.is_a?(Task) }
      @paper = @model_hash.values.detect { |value| value.is_a?(Paper) }
      @journal = @model_hash.values.detect { |value| value.is_a?(Journal) }
    end

    def journal
      @journal ||= paper.try(:journal)
    end

    def paper
      @paper ||= task.try(:paper) || fallback_to_first_possible_paper_reference
    end

    def task
      @task
    end

    def to_database_safe_hash
      model_hash.each_with_object({}) do |(key, model), safe_hash|
        safe_hash[key] = [model.model_name.name, model.id]
      end
    end

    private

    # This should be called if you cannot find a paper through other means.
    # It will look for a :paper method on all models in the @model_hash
    # and return the first one with a value.
    def fallback_to_first_possible_paper_reference
      model = @model_hash.values.detect { |model| model.try(:paper) }
      model.try(:paper)
    end
  end
end
