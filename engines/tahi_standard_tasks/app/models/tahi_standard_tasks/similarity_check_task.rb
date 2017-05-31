module TahiStandardTasks
  # The model class for the Similarity Check task, which is
  # used by Admins and Staff Admins for running a check against the iThenticate
  # api to generate a plagiarism report.
  class SimilarityCheckTask < Task
    has_many :ithenticate_checks, foreign_key: 'task_id', dependent: :destroy

    DEFAULT_TITLE = 'Similarity Check'.freeze
    DEFAULT_ROLE_HINT = 'admin'.freeze

    def active_model_serializer
      TahiStandardTasks::SimilarityCheckTaskSerializer
    end
  end
end
