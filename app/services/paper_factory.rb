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

  def create
    Paper.transaction do
      add_creator_as_collaborator
      if paper.valid?
        if template
          paper.save!
          add_decision
          add_phases_and_tasks
          add_creator_as_author!
        else
          paper.errors.add(:paper_type, "is not valid")
        end
      end
    end
  end

  def add_phases_and_tasks
    template.phase_templates.each do |phase_template|
      phase = paper.phases.create!(name: phase_template['name'])

      phase_template.task_templates.each do |task_template|

        TaskFactory.create(task_template.journal_task_type.kind,
                        phase: phase,
                        creator: creator,
                        title: task_template.title,
                        body: task_template.template,
                        role: task_template.journal_task_type.role)
      end
    end
  end

  private

  def template
    @template ||= paper.journal.manuscript_manager_templates.find_by(paper_type: paper.paper_type)
  end

  def add_creator_as_author!
    DefaultAuthorCreator.new(paper, creator).create!
  end

  def add_decision
    paper.decisions.create!
  end

  def add_creator_as_collaborator
    paper.paper_roles.build(user: creator, role: PaperRole::COLLABORATOR)
  end
end
