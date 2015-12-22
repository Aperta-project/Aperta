class PaperFactory
  attr_reader :paper, :creator

  def self.create(paper_params, creator)
    paper = creator.submitted_papers.build(paper_params)
    pf = new(paper, creator)
    pf.create
    pf.paper
  end

  def initialize(paper, creator)
    @paper = paper
    @creator = creator
  end

  def create
    Paper.transaction do
      add_creator_as_collaborator
      return unless paper.valid?
        if template
          paper.save!
          add_decision
          add_phases_and_tasks
          add_creator_as_author!
        else
          paper.errors.add(:paper_type, 'is not valid')
        end
    end
  end

  def add_phases_and_tasks
    template.phase_templates.each do |phase_template|
      phase = paper.phases.create!(name: phase_template['name'])
      phase_template.task_templates.each do |task_template|
        create_task_from_template(task_template, phase)
      end
    end
  end

  private

  def template
    @template ||= paper.journal.manuscript_manager_templates
                  .find_by(paper_type: paper.paper_type)
  end

  def create_task_from_template(task_template, phase)
    task = TaskFactory.create(task_template.journal_task_type.kind,
                              phase: phase,
                              creator: creator,
                              title: task_template.title,
                              body: task_template.template,
                              old_role: task_template.journal_task_type.old_role,
                              notify: false)
    task.paper_creation_hook(paper) if task.respond_to?(:paper_creation_hook)
  end

  def add_creator_as_author!
    DefaultAuthorCreator.new(paper, creator).create!
  end

  def add_decision
    paper.decisions.create!
  end

  def add_creator_as_collaborator
    paper.paper_roles.build(user: creator, old_role: PaperRole::COLLABORATOR)
  end
end
