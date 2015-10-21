module TahiStandardTasks
  class TaxonTaskSerializer < ::TaskSerializer
    has_many :nested_questions, embed: :ids, include: true
  end
end
