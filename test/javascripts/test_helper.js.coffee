# Teaspoon includes some support files, but you can use anything from your own support path too.
# require support/sinon
# require support/your-support-file
#
# PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
# Use this polyfill to avoid the confusion.
# require support/bind-poly
#
# Deferring execution
# If you're using CommonJS, RequireJS or some other asynchronous library you can defer execution. Call
# Teaspoon.execute() after everything has been loaded. Simple example of a timeout:
#
# Teaspoon.defer = true
# setTimeout(Teaspoon.execute, 1000)
#
# Matching files
# By default Teaspoon will look for files that match _test.{js,js.coffee,.coffee}. Add a filename_test.js file in your
# test path and it'll be included in the default suite automatically. If you want to customize suites, check out the
# configuration in config/initializers/teaspoon.rb
#
# Manifest
# If you'd rather require your test files manually (to control order for instance) you can disable the suite matcher in
# the configuration and use this file as a manifest.
#
# For more information: http://github.com/modeset/teaspoon
#
# You can require your own javascript files here. By default this will include everything in application, however you
# may get better load performance if you require the specific files that are being used in the test that tests them.
#
#= require support/bind-poly
#= require support/sinon
#= require application
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
