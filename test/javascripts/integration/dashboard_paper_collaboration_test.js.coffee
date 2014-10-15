setupEventStream = ->
  store = ETahi.__container__.lookup "store:main"
  es = ETahi.EventStream.create
          store: store
          init: ->
  [es, store]

createDashboardDataWithLitePaper = (paperCount, litePaper) ->
  ef = ETahi.Factory
  litePapers = []
  for i in [1..paperCount] by 1
    lp = ef.createLitePaper
      id: i
      title: "Fake Paper Long Title #{i}"
      short_title: "Fake Paper Short Title #{i}"
      submitted: false
    lp.roles = ['Collaborator']
    lp.related_at_date = "2014-09-28T13:54:58.028Z"
    litePapers.pushObject(lp)
  litePapers.pushObject(litePaper) if litePaper
  paperIds = litePapers.map (lp) -> lp.id

  [litePapers, [
    id: 1
    user_id: 1
    paper_ids: paperIds
    total_paper_count: litePapers.length
    total_page_count: 1
  ]]


module 'Integration: Dashboard',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true

    [litePapers, dashboards] = createDashboardDataWithLitePaper(2)
    TahiTest.dashboardResponse =
      users: [fakeUser]
      affiliations: []
      lite_papers: litePapers
      dashboards: dashboards

    adminJournalsResponse = {}

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify TahiTest.dashboardResponse
    ]

    server.respondWith 'GET', '/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
    ]

test 'When user is added as a collaborator on paper', ->
  ef = ETahi.Factory
  lp = ef.createLitePaper
    id: 370
    title: "Event-streamed paper"
    short_title: "new one"
    submitted: false
  lp.roles = ['Collaborator']
  lp.related_at_date = "2014-09-29T13:54:58.028Z"

  [litePapers, dashboards] = createDashboardDataWithLitePaper(2, lp)

  visit '/'
  .then ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 2
  andThen ->
    # receives eventstream push as collaborator
    [es, store] = setupEventStream()
    data =
      action: 'created'
      dashboard: dashboards[0]
      lite_papers: litePapers
      users: [fakeUser]

    Ember.run =>
      es.msgResponse(data)
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 3

test 'When paper is added, only shows if user is allowed to see the paper', ->
  ef = ETahi.Factory
  lp = ef.createLitePaper
    id: 370
    title: "Event-streamed paper"
    short_title: "new one"
    submitted: false
  lp.roles = []
  lp.related_at_date = "2014-09-29T13:54:58.028Z"

  [litePapers, dashboards] = createDashboardDataWithLitePaper(2, lp)

  visit '/'
  .then ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 2
  andThen ->
    # receives eventstream push as collaborator
    [es, store] = setupEventStream()
    data =
      action: 'created'
      dashboard: dashboards[0]
      lite_papers: litePapers
      users: [fakeUser]

    Ember.run =>
      es.msgResponse(data)
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 2


test 'When user is removed from collaborating on paper', ->
  ef = ETahi.Factory
  [litePapers, dashboards] = createDashboardDataWithLitePaper(2)

  visit '/'
  .then ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 2
  andThen ->
    # receives eventstream push to remove collaboration
    [es, store] = setupEventStream()
    data =
      action: "destroyed"
      lite_papers: [1]

    Ember.run =>
      es.msgResponse(data)
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 1
