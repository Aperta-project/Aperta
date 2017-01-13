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
      @paper ||= task.try(:paper)
    end

    def task
      @task
    end

    def to_database_safe_hash
      model_hash.each_with_object({}) do |(key, model), safe_hash|
        safe_hash[key] = [model.model_name.name, model.id]
      end
    end
  end
end
