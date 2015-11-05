JournalTaskType.create!([
  {journal_id: 1, title: "Ad-hoc", role: "user", kind: "Task"},
  {journal_id: 1, title: "Authors", role: "author", kind: "TahiStandardTasks::AuthorsTask"},
  {journal_id: 1, title: "Competing Interests", role: "author", kind: "TahiStandardTasks::CompetingInterestsTask"},
  {journal_id: 1, title: "Cover Letter", role: "author", kind: "TahiStandardTasks::CoverLetterTask"},
  {journal_id: 1, title: "Data Availability", role: "author", kind: "TahiStandardTasks::DataAvailabilityTask"},
  {journal_id: 1, title: "Ethics Statement", role: "author", kind: "TahiStandardTasks::EthicsTask"},
  {journal_id: 1, title: "Figures", role: "author", kind: "TahiStandardTasks::FigureTask"},
  {journal_id: 1, title: "Financial Disclosure", role: "author", kind: "TahiStandardTasks::FinancialDisclosureTask"},
  {journal_id: 1, title: "Assign Admin", role: "admin", kind: "TahiStandardTasks::PaperAdminTask"},
  {journal_id: 1, title: "Invite Editor", role: "admin", kind: "TahiStandardTasks::PaperEditorTask"},
  {journal_id: 1, title: "Invite Reviewers", role: "custom", kind: "TahiStandardTasks::PaperReviewerTask"},
  {journal_id: 1, title: "Production Metadata", role: "editor", kind: "TahiStandardTasks::ProductionMetadataTask"},
  {journal_id: 1, title: "Publishing Related Questions", role: "author", kind: "TahiStandardTasks::PublishingRelatedQuestionsTask"},
  {journal_id: 1, title: "Register Decision", role: "editor", kind: "TahiStandardTasks::RegisterDecisionTask"},
  {journal_id: 1, title: "Reporting Guidelines", role: "author", kind: "TahiStandardTasks::ReportingGuidelinesTask"},
  {journal_id: 1, title: "Reviewer Candidates", role: "author", kind: "TahiStandardTasks::ReviewerRecommendationsTask"},
  {journal_id: 1, title: "Reviewer Report", role: "reviewer", kind: "TahiStandardTasks::ReviewerReportTask"},
  {journal_id: 1, title: "Revise Task", role: "author", kind: "TahiStandardTasks::ReviseTask"},
  {journal_id: 1, title: "Supporting Info", role: "author", kind: "TahiStandardTasks::SupportingInformationTask"},
  {journal_id: 1, title: "New Taxon", role: "author", kind: "TahiStandardTasks::TaxonTask"},
  {journal_id: 1, title: "Upload Manuscript", role: "author", kind: "TahiUploadManuscript::UploadManuscriptTask"},
  {journal_id: 1, title: "Changes For Author", role: "author", kind: "PlosBioTechCheck::ChangesForAuthorTask"},
  {journal_id: 1, title: "Final Tech Check", role: "custom", kind: "PlosBioTechCheck::FinalTechCheckTask"},
  {journal_id: 1, title: "Initial Tech Check", role: "custom", kind: "PlosBioTechCheck::InitialTechCheckTask"},
  {journal_id: 1, title: "Revision Tech Check", role: "custom", kind: "PlosBioTechCheck::RevisionTechCheckTask"},
  {journal_id: 1, title: "Editor Discussion", role: "editor", kind: "PlosBioInternalReview::EditorsDiscussionTask"},
  {journal_id: 1, title: "Billing", role: "author", kind: "PlosBilling::BillingTask"},
  {journal_id: 1, title: "Assign Team", role: "admin", kind: "Tahi::AssignTeam::AssignTeamTask"},
  {journal_id: 1, title: "Test Task", role: "user", kind: "InvitableTask"}
])
Journal.create!([
  {name: "PLOS Developers", logo: nil, epub_cover: nil, epub_css: nil, pdf_css: nil, manuscript_css: nil, description: "If you are a developer, you are in the right place for fun, for science, and for publication.", doi_publisher_prefix: "10.1371", doi_journal_prefix: "devs", last_doi_issued: "100014"}
])
Role.create!([
  {name: "Admin", journal_id: 1, can_administer_journal: true, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: true, kind: "admin", can_view_flow_manager: true},
  {name: "Editor", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "editor", can_view_flow_manager: false},
  {name: "Flow Manager", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "flow manager", can_view_flow_manager: true}
])
ManuscriptManagerTemplate.create!([
  {paper_type: "Research", journal_id: 1}
])
PhaseTemplate.create!([
  {name: "Submission Data", manuscript_manager_template_id: 1, position: 1},
  {name: "Invite Editor", manuscript_manager_template_id: 1, position: 2},
  {name: "Invite Reviewers", manuscript_manager_template_id: 1, position: 3},
  {name: "Get Reviews", manuscript_manager_template_id: 1, position: 4},
  {name: "Make Decision", manuscript_manager_template_id: 1, position: 5}
])
TaskTemplate.create!([
  {journal_task_type_id: 7, phase_template_id: 1, template: [], title: "Figures", position: 1},
  {journal_task_type_id: 19, phase_template_id: 1, template: [], title: "Supporting Info", position: 2},
  {journal_task_type_id: 2, phase_template_id: 1, template: [], title: "Authors", position: 3},
  {journal_task_type_id: 21, phase_template_id: 1, template: [], title: "Upload Manuscript", position: 4},
  {journal_task_type_id: 4, phase_template_id: 1, template: [], title: "Cover Letter", position: 5},
  {journal_task_type_id: 10, phase_template_id: 2, template: [], title: "Invite Editor", position: 1},
  {journal_task_type_id: 9, phase_template_id: 2, template: [], title: "Assign Admin", position: 2},
  {journal_task_type_id: 11, phase_template_id: 3, template: [], title: "Invite Reviewers", position: 1},
  {journal_task_type_id: 14, phase_template_id: 5, template: [], title: "Register Decision", position: 1}
])
