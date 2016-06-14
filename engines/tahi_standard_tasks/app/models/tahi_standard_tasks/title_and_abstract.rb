module TahiStandardTasks
  # The model class for the Title And Abstract task, which is
  # used by editors to review and edit what iHat extracted from
  # an uploaded docx
  class TitleAndAbstract < Task
    DEFAULT_TITLE = 'Title And Abstract'
    DEFAULT_ROLE = 'editor'

    def active_model_serializer
      TahiStandardTasks::TitleAndAbstractSerializer
    end
  end
end
