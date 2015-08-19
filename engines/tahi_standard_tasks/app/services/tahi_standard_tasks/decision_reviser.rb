module TahiStandardTasks
  class DecisionReviser
    attr_reader :task, :paper, :decision

    def initialize(register_decision_task, decision)
      @task = register_decision_task
      @paper = task.paper
      @decision = decision
    end

    def process!
      task.transaction do
        setup_paper!
        setup_revise_task!

        broadcast_revision
      end
    end

    private

    def setup_paper!
      paper.tap { |p|
        p.editable = true
        p.decisions.build
      }.save!
    end

    def setup_revise_task!
      if existing_revise_task = paper.tasks.find_by(type: "TahiStandardTasks::ReviseTask")
        existing_revise_task.incomplete!
      else
        create_revise_task!
      end
    end

    def create_revise_task!
      participants = [paper.creator, paper.editor].compact.uniq
      TaskFactory.build(TahiStandardTasks::ReviseTask,
                        title: "Revise Manuscript",
                        role: "author",
                        phase_id: task.phase.id,
                        body: [[{ type: 'text', value: task.public_send("#{decision.verdict}_letter") }]],
                        participants: participants,
                        completed: false
                       ).save!
    end

    def broadcast_revision
      # TahiNotifier.notify(event: "paper.revised", payload: { paper_id: paper.id })
    end
  end
end
