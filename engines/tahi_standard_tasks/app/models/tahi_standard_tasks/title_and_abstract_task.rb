module TahiStandardTasks
  # The model class for the Title And Abstract task, which is
  # used by editors to review and edit what iHat extracted from
  # an uploaded docx
  class TitleAndAbstractTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Title And Abstract'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    attr_accessor :paper_title, :paper_abstract

    after_save    :update_paper

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

    def self.setup_new_revision(paper, phase)
      existing_title_and_abstract_task = find_by(paper: paper)
      if existing_title_and_abstract_task
        existing_title_and_abstract_task
          .update(completed: false, phase: phase)
      else
        TaskFactory.create(self, paper: paper, phase: phase)
      end
    end

    private

    def update_paper
      paper.title = paper_title
      paper.abstract = (paper_abstract.blank? ? nil : paper_abstract)
      paper.save!
    end
  end
end
