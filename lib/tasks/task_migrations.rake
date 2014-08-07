namespace :data do

  desc "Create default task types for all journals"
  task :create_task_types => :environment do
    types = [
      {kind: "Task",                                          default_role: nil,        default_title: "Ad-Hoc"},
      {kind: "StandardTasks::AuthorsTask",                    default_role: "author",   default_title: "Add Authors"},
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
      {kind: "UploadManuscript::Task",                        default_role: "author",   default_title: "Upload Manuscript"},
    ]

    task_types = types.map do |attributes|
      TaskType.where(attributes).first_or_create
    end

    Journal.all.each do |journal|
      task_types.each do |task_type|
        jtt = journal.journal_task_types.where(task_type_id: task_type.id).first_or_create
        jtt.role ||= task_type.default_role
        jtt.title ||= task_type.default_title
        jtt.save
        jtt
      end
    end
  end

  task :shorten_supporting_information do
    Task.where(title: "Supporting Information").update_all(title: "Supporting Info")
  end

  desc "Destroy and recreate manuscript manager templates"
  task :reset_mmts => :environment do
    ManuscriptManagerTemplate.destroy_all
    Rake::Task["journal:create_default_templates"].invoke
  end

  desc "Reset references to Task subclasses"
  task :reset_task_types => [:reset_mmts, :migrate_namespacing]
end
