class PaperFactory
  attr_reader :paper, :creator

  def self.create(paper_params, creator)
    paper_params[:title] = 'Untitled' if paper_params[:title].blank?
    paper = Paper.new(paper_params)

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
      return unless paper.valid?
        if template
          paper.save!
          # TODO: This requires roles & permissions tables to exist. It should
          # be possible to create a paper for testing without them.
          add_creator_assignment!
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
    journal_task_type = task_template.journal_task_type
    task = TaskFactory.create(
      Task.safe_constantize(task_template.journal_task_type.kind),
      phase: phase,
      paper: phase.paper,
      creator: creator,
      title: task_template.title,
      body: task_template.template,
      old_role: journal_task_type.old_role,
      required_permissions: journal_task_type.required_permissions,
      notify: false)
    task.paper_creation_hook(paper) if task.respond_to?(:paper_creation_hook)
  end

  def add_creator_assignment!
    creator.assignments.create!(
      assigned_to: paper,
      role: paper.journal.creator_role
    )
  end

  def add_creator_as_author!
    DefaultAuthorCreator.new(paper, creator).create!
  end

  def add_decision
    paper.decisions.create!
  end
end
