module TahiStandardTasks
  # The model class for the Title And Abstract task, which is
  # used by editors to review and edit what iHat extracted from
  # an uploaded docx
  class TitleAndAbstractTask < Task
    DEFAULT_TITLE = 'Title And Abstract'
    DEFAULT_ROLE = 'editor'

    attr_accessor :paper_title, :paper_abstract
    after_save :update_paper

    def paper_title
      @paper_title || paper.title
    end

    def paper_abstract
      @paper_abstract || paper.abstract
    end

    def active_model_serializer
      TahiStandardTasks::TitleAndAbstractTaskSerializer
    end

    def self.permitted_attributes
      super << [:paper_title, :paper_abstract]
    end

    private

    def update_paper
      paper.title = paper_title
      paper.abstract = (paper_abstract.blank? ? nil : paper_abstract)

      paper.save!
    end
  end
end
