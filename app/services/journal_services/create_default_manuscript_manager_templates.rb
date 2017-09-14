module JournalServices
  class CreateDefaultManuscriptManagerTemplates < BaseService
    def self.call(journal)
      with_noisy_errors do
        mmt = journal.manuscript_manager_templates.create!(paper_type: 'Research')

        create_phase_template(name: "Submission Data", journal: journal, mmt: mmt,
                              phase_content: [
                                TahiStandardTasks::TitleAndAbstractTask,
                                TahiStandardTasks::FigureTask,
                                TahiStandardTasks::EarlyPostingTask,
                                TahiStandardTasks::SupportingInformationTask,
                                TahiStandardTasks::AuthorsTask,
                                TahiStandardTasks::UploadManuscriptTask,
                                CustomCard::Configurations::CoverLetter
                              ])

        create_phase_template(name: "Invite Editor", journal: journal, mmt: mmt,
                              phase_content: TahiStandardTasks::PaperEditorTask)

        create_phase_template(name: "Invite Reviewers", journal: journal, mmt: mmt,
                              phase_content: TahiStandardTasks::PaperReviewerTask)

        create_phase_template(name: "Get Reviews", journal: journal, mmt: mmt)

        create_phase_template(name: "Make Decision", journal: journal, mmt: mmt,
                              phase_content: TahiStandardTasks::RegisterDecisionTask)
      end
    end

    def self.create_phase_template(name:, journal:, mmt:, phase_content: [])
      mmt.phase_templates.create!(name: name).tap do |phase_template|
        Array(phase_content).each do |content|
          if content <= Task
            # create a new JournalTaskTemplate for a legacy Task
            journal_task_type = journal.journal_task_types.find_by!(kind: content)
            phase_template.task_templates.create!(title: journal_task_type.title, journal_task_type: journal_task_type)
          else
            # create a new Card via seed data and associate to JournalTaskTemplate
            card = CustomCard::Loader.load!(content, journal: journal).first
            phase_template.task_templates.create!(title: card.name, card: card)
          end
        end
      end
    end
  end
end
