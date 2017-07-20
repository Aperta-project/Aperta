module JournalServices
  class CreateDefaultManuscriptManagerTemplates < BaseService
    def self.call(journal)
      with_noisy_errors do
        mmt = journal.manuscript_manager_templates.create!(paper_type: 'Research')

        create_phase_template(name: "Submission Data", journal: journal, mmt: mmt,
                              items: [
                                TahiStandardTasks::TitleAndAbstractTask,
                                TahiStandardTasks::FigureTask,
                                TahiStandardTasks::EarlyPostingTask,
                                TahiStandardTasks::SupportingInformationTask,
                                TahiStandardTasks::AuthorsTask,
                                TahiStandardTasks::UploadManuscriptTask,
                                TahiStandardTasks::CoverLetterTask
                              ])

        create_phase_template(name: "Invite Editor", journal: journal, mmt: mmt,
                              items: TahiStandardTasks::PaperEditorTask)

        create_phase_template(name: "Invite Reviewers", journal: journal, mmt: mmt,
                              items: TahiStandardTasks::PaperReviewerTask)

        create_phase_template(name: "Get Reviews", journal: journal, mmt: mmt)

        create_phase_template(name: "Make Decision", journal: journal, mmt: mmt,
                              items: TahiStandardTasks::RegisterDecisionTask)
      end
    end

    def self.create_phase_template(name:, journal:, mmt:, items: [])
      mmt.phase_templates.create!(name: name).tap do |phase_template|
        Array(items).each do |item|
          if item <= Task
            # create a new JournalTaskTemplate for a legacy Task
            jtt = journal.journal_task_types.find_by!(kind: item)
            phase_template.task_templates.create!(title: jtt.title, journal_task_type: jtt)
          else
            # create a new Card via seed data and associate to JournalTaskTemplate
            card = CustomCard::Loader.load!(item, journal: journal).first
            phase_template.task_templates.create!(title: card.name, card: card)
          end
        end
      end
    end
  end
end
