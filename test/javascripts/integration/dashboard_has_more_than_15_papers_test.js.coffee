createDashboardData = (paperCount) ->

module 'Integration: Dashboard',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true
    TahiTest.paperId = 934
    TahiTest.adminJournalId = 412
    TahiTest.adminRoleId = 98
    TahiTest.paperCount = 42
    TahiTest.pageCount = 3

    TahiTest.Factory =
      litePaper: (params) ->
        litePapers = []
        for i in [1..params.count] by 1
          litePapers.push
            id: i
            title: "Fake Paper Long Title #{i}"
            paper_id: i
            short_title: "Fake Paper Short Title #{i}"
            submitted: false
            roles: ['My Paper']
        litePapers

    litePapersResponse =
      lite_papers: TahiTest.Factory.litePaper count: TahiTest.paperCount

    TahiTest.dashboardResponse =
      users: [fakeUser]
      affiliations: []
      lite_papers: litePapersResponse.lite_papers[0..14]
      dashboards: [
        id: 1
        user_id: 1
        paper_ids: [1..15]
        total_paper_count: TahiTest.paperCount
        total_page_count: TahiTest.pageCount
        administered_journals: [
          id: TahiTest.adminJournalId
          name: "Fake Journal"
          logo_url: "https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/3/thumbnail_Screen%2BShot%2B2014-06-10%2Bat%2B2.59.37%2BPM.png
          paper_types: ["Research"]
          task_types: [
            "FinancialDisclosure::Task"
            "StandardTasks::PaperAdminTask"
            "StandardTasks::PaperEditorTask"
            "StandardTasks::PaperReviewerTask"
            "StandardTasks::ReviewerReportTask"
            "StandardTasks::RegisterDecisionTask"
            "ReviewerReportTask"
            "StandardTasks::AuthorsTask"
            "StandardTasks::CompetingInterestsTask"
            "StandardTasks::DataAvailabilityTask"
            "StandardTasks::FigureTask"
            "StandardTasks::TechCheckTask"
            "SupportingInformation::Task"
            "UploadManuscript::Task"
          ]
          manuscript_css: null
        ]
      ]

    adminJournalsResponse = {}

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify TahiTest.dashboardResponse
    ]

    server.respondWith 'GET', '/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
    ]

    # end_index: (page number * 15) - 1
    # begin_index: end_index - 15
    server.respondWith 'GET', '/lite_papers?page_number=2', [
      200, 'Content-Type': 'application/json', JSON.stringify (lite_papers: litePapersResponse.lite_papers[15..29])
    ]

    server.respondWith 'GET', '/lite_papers?page_number=3', [
      200, 'Content-Type': 'application/json', JSON.stringify (lite_papers: litePapersResponse.lite_papers[30..TahiTest.paperCount - 1])
    ]

test 'With more than 15 papers, there should be a "Load More" button if we are not at the last page', ->
  visit '/'
  .then ->
    ok exists '.load-more-papers'
    ok !Em.isEmpty find('.welcome-message').text().match(/You have 42 manuscripts/)
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 15
  click '.load-more-papers'
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 30
    ok exists '.load-more-papers'
  click '.load-more-papers'
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 42
    ok !exists '.load-more-papers'

