module 'Integration: Dashboard',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true
    TahiTest.paperId = 934
    TahiTest.adminJournalId = 412
    TahiTest.adminRoleId = 98
    TahiTest.paperCount = 15

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

    TahiTest.dashboardResponse =
      users: [fakeUser.user]
      affiliations: []
      lite_papers: TahiTest.Factory.litePaper count: TahiTest.paperCount
      dashboards: [
        id: 1
        user_id: 1
        paper_ids: [1..TahiTest.paperCount]
        paginate: false
        total_paper_count: TahiTest.paperCount
        administered_journals: [
          id: TahiTest.adminJournalId
          name: "Fake Journal"
          logo_url: "https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/logo/3/thumbnail_Screen%2BShot%2B2014-06-10%2Bat%2B2.59.37%2BPM.png?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=5w6R%2BYJolrrcs2Dc/ntqRy6/MyQ%3D&Expires=1405980361"
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
        ]
      ]

    adminJournalsResponse =
      roles: [
        id: TahiTest.adminRoleId
        kind: 'admin'
        name: 'Admin'
        required: true
        can_administer_journal: true
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: true
        journal_id: 3
      ]
      admin_journals: [
        id: TahiTest.adminJournalId
        name: 'Fake Journal'
        logo_url: 'https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/logo/3/thumbnail_Screen%2BShot%2B2014-06-10%2Bat%2B2.59.37%2BPM.png?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=kSWiz0HiOO0nUTMSpR/0DQp3j%2Bw%3D&Expires=1405980362'
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
        epub_cover_url: null
        epub_cover_file_name: null
        epub_css: null
        pdf_css: null
        manuscript_css: null
        description: 'This is a fake journal'
        paper_count: TahiTest.paperCount
        created_at: '2014-06-16T22:23:16.320Z'
        manuscript_manager_templates: [
          id: 5
          paper_type: 'Research'
          template:
            phases: [
              name: 'Submission Data'
              task_types: [
                'Declaration::Task'
                'StandardTasks::FigureTask'
                'SupportingInformation::Task'
                'StandardTasks::AuthorsTask'
                'UploadManuscript::Task'
              ]
            ,
              name: 'Assign Editor'
              task_types: [
                'PaperEditorTask'
                'StandardTasks::TechCheckTask'
                'PaperAdminTask'
              ]
            ,
              name: 'Assign Reviewers'
              task_types: ['PaperReviewerTask']
            ,
              name: 'Get Reviews'
              task_types: []
            ,
              name: 'Make Decision'
              task_types: ['RegisterDecisionTask']
            ]

          journal_id: TahiTest.adminJournalId
        ]
        role_ids: [TahiTest.adminRoleId]
      ]

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify TahiTest.dashboardResponse
    ]

    server.respondWith 'GET', '/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
    ]

test 'There should not be a "Load More" button if there are less than 15 papers', ->
  visit '/'
  andThen ->
    ok !Em.isEmpty find('.welcome-message').text().match(/You have 15 papers/)
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, TahiTest.paperCount
    ok !exists '.load-more-papers'

test 'There should be a "Load More" button if the response has paginate: true', ->
  dashboardResponse = TahiTest.dashboardResponse
  dashboardResponse.dashboards[0].paginate = true
  dashboardResponse.dashboards[0].total_paper_count = 20
  server.respondWith 'GET', '/dashboards', [
    200, 'Content-Type': 'application/json', JSON.stringify dashboardResponse
  ]
  visit '/'
  .then ->
    ok exists '.load-more-papers'
    ok !Em.isEmpty find('.welcome-message').text().match(/You have 20 papers/)
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 15
  click '.load-more-papers'
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 20
    ok !exists '.load-more-papers'
