module 'Integration: Navbar',
  teardown: -> ETahi.reset()

  setup: ->
    setupApp integration: true
    TahiTest.paperId = 934
    TahiTest.journalId = 209
    TahiTest.adminJournalId = 412
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
          logo_url: "https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/logo/3/thumbnail_Screen%2BShot%2B2014-06-10%2Bat%2B2.59.37%2BPM.png?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=5w6R%2BYJolrrcs2Dc/ntqRy6/MyQ%3D&Expires=1405980361"
          paper_types: ["Research"]
          task_types: [
          ]
          manuscript_css: null
        ]
      ]

    TahiTest.adminJournalsResponse =
      roles: [
        id: 7
        kind: "admin"
        name: "Admin"
        required: true
        can_administer_journal: true
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: true
        journal_id: TahiTest.journalId
      ]
      admin_journals: [
        id: TahiTest.journalId
        name: "Test Journal of America"
        logo_url: "https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/logo/3/Screen%2BShot%2B2014-06-10%2Bat%2B2.59.37%2BPM.png?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=l34/IdieeCkMGABO7KcBNK1n8Q4%3D&Expires=1405467848"
        paper_types: ["Research"]
        task_types: [
        ]
        epub_cover_url: null
        epub_cover_file_name: null
        epub_css: null
        pdf_css: null
        manuscript_css: null
        description: "This is a test journal"
        paper_count: 3
        created_at: "2014-06-16T22:23:16.320Z"
        manuscript_manager_templates: [
          id: 5
          paper_type: "Research"
          template:
            phases: [
              name: "Submission Data"
              task_types: [
              ]
              ,
              name: "Assign Editor"
              task_types: [
              ]
              ,
              name: "Assign Reviewers"
              task_types: []
              ,
              name: "Get Reviews"
              task_types: []
              ,
              name: "Make Decision"
              task_types: []
            ]
          journal_id: TahiTest.journalId
        ]
        role_ids: [7]
      ]

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify TahiTest.dashboardResponse
    ]


test 'navbar link as User', ->
  server.respondWith 'GET', '/admin/journals', [
    200, 'Content-Type': 'application/json', JSON.stringify {}
  ]

  visit '/'
  .then ->
    ok $('#top-nav').text().indexOf('Flow Manager') is -1
    ok $('#top-nav').text().indexOf('Admin') is -1
    ok $('#top-nav').text().indexOf(@fakeUser.username) isnt -1

test 'navbar links as Admin', ->
  server.respondWith 'GET', '/admin/journals', [
    200, 'Content-Type': 'application/json', JSON.stringify TahiTest.adminJournalsResponse
  ]

  store = ETahi.__container__.lookup 'store:main'
  store.find 'user', window.currentUserId
  .then (currentUser) -> currentUser.set 'admin', true

  visit '/'
  .then ->
    ok $('#top-nav').text().indexOf('Flow Manager') isnt -1
    ok $('#top-nav').text().indexOf('Admin') isnt -1
    ok $('#top-nav').text().indexOf(@fakeUser.username) isnt -1
