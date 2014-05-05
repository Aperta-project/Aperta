class PaperFactory
  attr_reader :paper, :author

  def self.create(paper_params, author)
    paper = author.papers.build(paper_params)
    pf = new(paper, author)
    pf.create
    pf.paper
  end

  def initialize(paper, author)
    @paper = paper
    @author = author
  end

  def apply_template
    template.phases.each_with_index do |template_phase|
      phase = paper.phases.create!(name: template_phase['name'])
      template_phase['task_types'].each do |task_klass|
        create_task(task_klass, phase)
      end
    end
  end

  def create
    paper.add_author(author)
    if paper.valid?
      paper.transaction do
        if template
          paper.save
          apply_template
        else
          paper.errors.add(:paper_type, "is not valid")
        end
      end
    end
  end

  def create_task(task_klass, phase)
    task = nil
    begin
      task = task_klass.constantize.new(phase: phase)
    rescue NameError => e
    end

    if task.role == 'author'
      task.assignee = author
    end
    task.save!
  end

  def template
    @template ||= paper.journal.mmt_for_paper_type(paper.paper_type)
  end
end
