class PaperFactory
  attr_reader :paper, :submitter

  def self.create(paper_params, submitter)
    paper = submitter.submitted_papers.build(paper_params)
    pf = new(paper, submitter)
    pf.create
    pf.paper
  end

  def initialize(paper, submitter)
    @paper = paper
    @submitter = submitter
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
      add_collaborator(paper, submitter)
      if paper.valid?
        if template
          paper.save
          apply_template
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
      task.participants << submitter if task.manuscript_information_task?
      task.save!
    end
  end

  def template
    @template ||= paper.journal.mmt_for_paper_type(paper.paper_type)
  end

  private

  def add_collaborator(paper, user)
    paper.paper_roles.build(user: user, role: PaperRole::COLLABORATOR)
  end
end
