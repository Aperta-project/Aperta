module TahiStandardTasks
  # The model class for the Similarity Check task, which is
  # used by Admins and Staff Admins for running a check against the iThenticate
  # api to generate a plagiarism report.
  class SimilarityCheckTask < Task
    DEFAULT_TITLE = 'Similarity Check'.freeze
    DEFAULT_ROLE_HINT = 'admin'.freeze

    def active_model_serializer
      TahiStandardTasks::SimilarityCheckTaskSerializer
    end
  end
end
