module JournalServices
  class CreateDefaultManuscriptManagerTemplates < BaseService
    def self.call(journal)
      with_noisy_errors do
        mmt = journal.manuscript_manager_templates.create!(paper_type: 'Research')
        task_types = journal.journal_task_types
        raise "No task types configured for journal #{journal.id}" unless task_types.present?

        phase = mmt.phase_templates.create! name: "Submission Data"
        make_tasks phase, task_types,
          TahiStandardTasks::FigureTask,
          TahiStandardTasks::SupportingInformationTask,
          TahiStandardTasks::AuthorsTask,
          TahiUploadManuscript::UploadManuscriptTask,
          TahiStandardTasks::CoverLetterTask

        phase = mmt.phase_templates.create! name: "Invite Editor"
        make_tasks phase, task_types,
          TahiStandardTasks::PaperEditorTask,
          TahiStandardTasks::PaperAdminTask

        phase = mmt.phase_templates.create! name: "Invite Reviewers"
        make_tasks phase, task_types, TahiStandardTasks::PaperReviewerTask

        phase = mmt.phase_templates.create! name: "Get Reviews"

        phase = mmt.phase_templates.create! name: "Make Decision"
        make_tasks phase, task_types, TahiStandardTasks::RegisterDecisionTask
      end
    end

    def self.make_tasks(phase, task_types, *tasks)
      tasks.each do |kind|
        jtt = task_types.find_by(kind: kind)
        phase.task_templates.create! title: jtt.title, journal_task_type: jtt
      end
    end
  end
end
