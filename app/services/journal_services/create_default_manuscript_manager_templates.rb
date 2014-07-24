module JournalServices
  class CreateDefaultManuscriptManagerTemplates < BaseService
    def self.call(journal)
      with_noisy_errors do
        journal.manuscript_manager_templates.create!(
          paper_type: "Research",
          template: {
            phases: [{
              name: "Submission Data",
              task_types: [StandardTasks::FigureTask, SupportingInformation::Task, StandardTasks::AuthorsTask, UploadManuscript::Task].map(&:to_s)
            }, {
              name: "Assign Editor",
              task_types: [PaperEditorTask, StandardTasks::TechCheckTask, PaperAdminTask].map(&:to_s)
            }, {
              name: "Assign Reviewers",
              task_types: [PaperReviewerTask].map(&:to_s)
            }, {
              name: "Get Reviews",
              task_types: []
            }, {
              name: "Make Decision",
              task_types: [RegisterDecisionTask].map(&:to_s)
            }]
          }
        )
      end
    end
  end
end
