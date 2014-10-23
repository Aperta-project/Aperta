module TaskServices
  class CreateTaskTypes
    def self.call
      types = [
        {kind: "PlosAuthors::PlosAuthorsTask",                  default_role: "author",   default_title: "Add Authors"},
        {kind: "StandardTasks::CompetingInterestsTask",         default_role: "author",   default_title: "Competing Interests"},
        {kind: "StandardTasks::DataAvailabilityTask",           default_role: "author",   default_title: "Data Availability"},
        {kind: "StandardTasks::EthicsTask",                     default_role: "author",   default_title: "Add Ethics Statement"},
        {kind: "StandardTasks::FigureTask",                     default_role: "author",   default_title: "Upload Figures"},
        {kind: "StandardTasks::FinancialDisclosureTask",        default_role: "author",   default_title: "Financial Disclosure"},
        {kind: "StandardTasks::PaperAdminTask",                 default_role: "admin",    default_title: "Assign Admin"},
        {kind: "StandardTasks::PaperEditorTask",                default_role: "admin",    default_title: "Assign Editor"},
        {kind: "StandardTasks::PaperReviewerTask",              default_role: "editor",   default_title: "Assign Reviewers"},
        {kind: "StandardTasks::PublishingRelatedQuestionsTask", default_role: "author",   default_title: "Publishing Related Questions"},
        {kind: "StandardTasks::RegisterDecisionTask",           default_role: "editor",   default_title: "Register Decision"},
        {kind: "StandardTasks::ReportingGuidelinesTask",        default_role: "author",   default_title: "Reporting Guidelines"},
        {kind: "StandardTasks::ReviewerReportTask",             default_role: "reviewer", default_title: "Reviewer Report"},
        {kind: "StandardTasks::TaxonTask",                      default_role: "author",   default_title: "New Taxon"},
        {kind: "StandardTasks::TechCheckTask",                  default_role: "admin",    default_title: "Tech Check"},
        {kind: "SupportingInformation::Task",                   default_role: "author",   default_title: "Supporting Info"},
        {kind: "Task",                                          default_role: nil,        default_title: "Ad-Hoc"},
        {kind: "MessageTask",                                   default_role: nil,        default_title: "Message Task"},
        {kind: "UploadManuscript::Task",                        default_role: "author",   default_title: "Upload Manuscript"},
      ]

      # create or update task_types
      current_task_types = types.map do |attributes|
        TaskType.where(kind: attributes[:kind]).first_or_create.tap do |tt|
          tt.update_attributes(attributes)
        end
      end

      # destroy any leftover task_types
      comparisons = Array.compare(TaskType.all, current_task_types)
      comparisons[:removed].each(&:destroy)
    end
  end
end
