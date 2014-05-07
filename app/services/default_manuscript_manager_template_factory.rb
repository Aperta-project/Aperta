class DefaultManuscriptManagerTemplateFactory

  def self.build
    ManuscriptManagerTemplate.new(
      paper_type: "Research",
      template: {
        phases: [{
          name: "Submission Data",
          task_types: [DeclarationTask, StandardTasks::FigureTask, StandardTasks::AuthorsTask, UploadManuscriptTask].map(&:to_s)
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
