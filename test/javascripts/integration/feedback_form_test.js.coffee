module 'Integration: Feedback Form',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true
    TahiTest.dashboardResponse =
      users: [fakeUser]
      dashboards: [
        id: 1
        user_id: 1
        paper_ids: []
        total_paper_count: TahiTest.paperCount
        total_page_count: TahiTest.pageCount
      ]

    adminJournalsResponse = {}

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify TahiTest.dashboardResponse
    ]

    server.respondWith 'GET', "/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'POST', "/feedback", [
      201, "Content-Type": "application/json", "{}"
    ]

test 'clicking the feedback button sends feedback to the backend', ->
  visit '/'

  .then ->
    click '.navigation-toggle'
  .andThen ->
    click '.navigation-item-feedback'
    ok exists '.overlay'
  .andThen ->
    fillIn 'form textarea', "My feedback"
    click '.overlay-footer button'
  .andThen ->
    ok find('.overlay .thanks')
