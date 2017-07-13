module JournalServices
  class CreateDefaultManuscriptManagerTemplates < BaseService
    def self.call(journal)
      with_noisy_errors do
        mmt = journal.manuscript_manager_templates.create!(paper_type: 'Research')
        task_types = journal.journal_task_types
        raise "No task types configured for journal #{journal.id}" unless task_types.present?

        phase = mmt.phase_templates.create! name: "Submission Data"
        make_tasks journal, phase, task_types,
          TahiStandardTasks::FigureTask,
          TahiStandardTasks::EarlyPostingTask,
          TahiStandardTasks::SupportingInformationTask,
          TahiStandardTasks::AuthorsTask,
          TahiStandardTasks::UploadManuscriptTask,
          TahiStandardTasks::CoverLetterTask,
          CustomCard::Configurations::CoverLetter

        phase = mmt.phase_templates.create! name: "Invite Editor"
        make_tasks journal, phase, task_types, TahiStandardTasks::PaperEditorTask

        phase = mmt.phase_templates.create! name: "Invite Reviewers"
        make_tasks journal, phase, task_types, TahiStandardTasks::PaperReviewerTask

        phase = mmt.phase_templates.create! name: "Get Reviews"

        phase = mmt.phase_templates.create! name: "Make Decision"
        make_tasks journal, phase, task_types, TahiStandardTasks::RegisterDecisionTask
      end
    end

    def self.make_tasks(journal, phase, task_types, *items)
      items.each do |item|
        if item <= Task
          # create a new JournalTaskTemplate for a legacy Task
          jtt = task_types.find_by(kind: item)
          phase.task_templates.create! title: jtt.title, journal_task_type: jtt
        else
          # crete a new Card using seed data and associate to JournalTaskTemplate
          card = CustomCard::Loader.load(item, journal: journal).first
          phase.task_templates.create!(title: card.name, card: card)
        end
      end
    end
  end
end
