module JournalServices
  class CreateDefaultManuscriptManagerTemplates < BaseService
    def self.call(journal)
      with_noisy_errors do
        mmt = journal.manuscript_manager_templates.create!(paper_type: 'Research')
        task_types = journal.journal_task_types.includes(:task_type)

        phase = mmt.phase_templates.create! name: "Submission Data"
        make_tasks phase, task_types, StandardTasks::FigureTask, SupportingInformation::Task, StandardTasks::AuthorsTask, UploadManuscript::Task

        phase = mmt.phase_templates.create! name: "Assign Editor"
        make_tasks phase, task_types, StandardTasks::PaperEditorTask, StandardTasks::TechCheckTask, StandardTasks::PaperAdminTask

        phase = mmt.phase_templates.create! name: "Assign Reviewers"
        make_tasks phase, task_types, StandardTasks::PaperReviewerTask

        phase = mmt.phase_templates.create! name: "Get Reviews"

        phase = mmt.phase_templates.create! name: "Make Decision"
        make_tasks phase, task_types, StandardTasks::RegisterDecisionTask
      end
    end

    def self.task_type(journal_task_types, type)
      jtt = journal_task_types.detect { |jtt| jtt.task_type.kind == type }
      { title: jtt.title, journal_task_type: jtt }
    end

    def self.make_tasks(phase, task_types, *tasks)
      tasks.each do |kind|
        phase.task_templates.create! task_type(task_types, kind.to_s)
      end
    end
  end
end
