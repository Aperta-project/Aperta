class PaperFactory
  attr_reader :paper, :creator

  def self.create(paper_params, creator)
    paper = creator.submitted_papers.build(paper_params)
    journal = paper.journal
    paper.doi = Doi.new(journal: journal).assign! if journal
    paper.editor_mode = 'html' if paper.editor_mode.nil?
    pf = new(paper, creator)
    pf.create
    pf.paper
  end

  def initialize(paper, creator)
    @paper = paper
    @creator = creator
  end

  def apply_template
    template.phase_templates.each do |phase_template|
      phase = paper.phases.create!(name: phase_template['name'])

      phase_template.task_templates.each do |task_template|
        create_task(task_template, phase)
      end
    end
  end

  def create
    Paper.transaction do
      add_collaborator(paper, creator)
      if paper.valid?
        if template
          paper.save!
          paper.decisions.create!
          apply_template
          add_creator_as_author!
        else
          paper.errors.add(:paper_type, "is not valid")
        end
      end
    end
  end

  def create_task(task_template, phase)
    task_klass = task_template.journal_task_type.kind.constantize

    task_klass.new.tap do |task|
      task.phase = phase
      task.title = task_template.title
      task.body = task_template.template
      task.role = task_template.journal_task_type.role
      task.participants << creator if task.submission_task?
      task.save!
    end
  end

  def template
    @template ||= paper.journal.mmt_for_paper_type(paper.paper_type)
  end

  private

  def add_creator_as_author!
    DefaultAuthorCreator.new(paper, creator).create!
  end

  def add_collaborator(paper, user)
    paper.paper_roles.build(user: user, role: PaperRole::COLLABORATOR)
  end
end
