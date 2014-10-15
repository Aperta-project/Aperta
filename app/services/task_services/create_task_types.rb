module TaskServices
  class CreateTaskTypes
    def self.call
      types = [
        {kind: "PlosAuthors::PlosAuthorsTask",                  default_role: "author",   default_title: "Add Plos Author"},
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
        {kind: "UploadManuscript::Task",                        default_role: "author",   default_title: "Upload Manuscript"},
      ]

      types.map do |attributes|
        TaskType.where(attributes).first_or_create
      end
    end
  end
end
