module Snapshot
  class TaxonTaskSerializer < BaseSerializer

    def initialize(task)
      @task = task
    end

    def snapshot
      taxon_task = []
      nested_questions = TahiStandardTasks::TaxonTask.nested_questions
      nested_questions.each do |question|
        serializer = Snapshot::NestedQuestionSerializer.new(question, @task)
        taxon_task << serializer.snapshot
      end
      taxon_task
    end
  end
end
