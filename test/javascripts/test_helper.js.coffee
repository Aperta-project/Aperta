#= require application
#= require sinon
#= require support/ember-qunit
#= require support/utils
#= require support/test_initializer
#= require_self
#= require_tree .

paper =
  lite_papers: [
    id: 12
    title: null
    paper_id: 12
    short_title: 'Paper'
    submitted: false
  ]
  users: [
    id: 1
    full_name: 'Fake User'
    avatar_url: '/images/profile-no-image.png'
    username: 'fakeuser'
    email: 'fakeuser@example.com'
    admin: true
    affiliation_ids: []
  ]
  affiliations: []
  surveys: [
    {
      id: 31
      question: 'COMPETING INTERESTS: do the authors have any competing interests?'
      answer: null
      declaration_task_id: 93
    }
    {
      id: 32
      question: 'ETHICS STATEMENT: (if applicable) the authors declare the following ethics statement:'
      answer: null
      declaration_task_id: 93
    }
  ]
  figures: []
  author_groups: [
    {
      id: 41
      name: 'First Author'
      author_ids: [12]
      paper_id: 12
    }
  ]
  authors: [
    id: 12
    first_name: 'Fake'
    middle_initial: null
    last_name: 'User'
    email: 'fakeuser@example.com'
    affiliation: null
    secondary_affiliation: null
    title: null
    corresponding: false
    deceased: false
    department: null
    position: 1
    author_group_id: 41
  ]
  supporting_information_files: []
  journals: [
    id: 3
    name: 'Fake Journal'
    logo_url: '/images/no-journal-image.gif'
    paper_types: ['Research']
    task_types: [
      'ReviewerReportTask'
      'PaperAdminTask'
      'UploadManuscript::Task'
      'PaperEditorTask'
      'Declaration::Task'
      'PaperReviewerTask'
      'RegisterDecisionTask'
      'StandardTasks::TechCheckTask'
      'StandardTasks::FigureTask'
      'StandardTasks::AuthorsTask'
      'SupportingInformation::Task'
      'DataAvailability::Task'
      'FinancialDisclosure::Task'
      'CompetingInterests::Task'
    ]
    manuscript_css: null
    reviewer_ids: []
  ]
  paper:
    id: 12
    short_title: 'Fake Paper'
    title: null
    body: null
    submitted: false
    paper_type: 'Research'
    status: null
    phase_ids: [40]
    figure_ids: []
    author_group_ids: [41]
    supporting_information_file_ids: []
    assignee_ids: [6]
    editor_ids: []
    reviewer_ids: []
    tasks: [
      {
        id: 93
        type: 'DeclarationTask'
      }
      {
        id: 94
        type: 'FigureTask'
      }
    ]
    journal_id: 3
