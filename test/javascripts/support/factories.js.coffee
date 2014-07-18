ETahi.FactoryAttributes = {}
ETahi.FactoryAttributes.journal =
  id: 1
  name: "Fake Journal"
  logo_url: "/images/no-journal-image.gif"
  paper_types: ["Research"]
  task_types: [
    "ReviewerReportTask"
    "PaperAdminTask"
    "UploadManuscript::Task"
    "PaperEditorTask"
    "Declaration::Task"
    "PaperReviewerTask"
    "RegisterDecisionTask"
    "StandardTasks::TechCheckTask"
    "StandardTasks::FigureTask"
    "StandardTasks::AuthorsTask"
    "SupportingInformation::Task"
    "DataAvailability::Task"
    "FinancialDisclosure::Task"
    "CompetingInterests::Task"
  ]
  manuscript_css: null

ETahi.FactoryAttributes.paper =
  id: 1
  short_title: "Paper"
  title: "Foo"
  body: null
  submitted: false
  paper_type: "Research"
  status: null
  phase_ids: []
  figure_ids: []
  author_group_ids: []
  supporting_information_file_ids: []
  assignee_ids: []
  editor_ids: []
  reviewer_ids: []
  tasks: []
  journal_id: 1

ETahi.FactoryAttributes.litePaper =
  id: 1
  title: "Foo"
  paper_id: 1
  short_title: "Paper"
  submitted: false

ETahi.Factory =
  create: (type, attrs) ->
    Ember.merge(ETahi.FactoryAttributes[type], attrs)

  createLitePaper: (paper, attrs) ->
    {short_title, title, id, submitted} = paper
    paper_id = id
    litePaperAttrs = {short_title, title, id, submitted, paper_id}
    Ember.merge(litePaperAttrs, attrs)
