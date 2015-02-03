`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`
`import { paperWithRoles } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import EventStream from 'tahi/services/event-stream'`

app = null
server = null
fakeUser = null

setupEventStream = ->
  store = getStore()
  es = EventStream.create
    store: store
    init: ->
  [es, store]

createDashboardDataWithLitePaper = (paperCount, litePaper) ->
  litePapers = []
  for i in [1..paperCount] by 1
    lp = Factory.createLitePaper
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

createDashboardDataWithLitePaperRoles = (roleArray) ->
  litePapers = roleArray.map (role, index) ->
    lp = Factory.createLitePaper
      id: index + 1
      title: "Fake Paper Long Title #{index}"
      short_title: "Fake Paper Short Title #{index}"
      submitted: false
    lp.roles = [role]
    lp.related_at_date = "2014-09-28T13:54:58.028Z"
    lp
  [litePapers, [
    id: 1
    user_id: 1
    paper_ids: litePapers.mapBy('id')
    total_paper_count: litePapers.length
    total_page_count: 1
  ]]


module 'Integration: Dashboard',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUser.user

    [litePapers, dashboards] = createDashboardDataWithLitePaper(2)

    dashboardResponse =
      users: [fakeUser]
      affiliations: []
      lite_papers: litePapers
      dashboards: dashboards

    adminJournalsResponse = {}

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify dashboardResponse
    ]

    server.respondWith 'GET', '/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
    ]

    server.respondWith 'GET', "/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

test 'The dashboard shows papers for a user if they have any role on the paper', ->
  roles = ['Collaborator', 'Reviewer', 'Editor', 'Admin', 'My Paper', 'Circus Clown']
  [litePapers, dashboards] = createDashboardDataWithLitePaperRoles(roles)
  dashboardResponse =
    users: [fakeUser]
    affiliations: []
    lite_papers: litePapers
    dashboards: dashboards

  server.respondWith 'GET', '/dashboards', [
    200, 'Content-Type': 'application/json', JSON.stringify dashboardResponse
  ]

  visit '/'
  .then ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 6, 'All papers with roles should be visible'

test 'When paper is added, only shows if user is allowed to see the paper', ->
  visit '/'
  .then ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 2
  andThen ->
    # receives paper update with no roles
    [es, store] = setupEventStream()
    paperPayload = Factory.createPayload('paper')
    records = paperWithRoles(200, [])
    paperPayload.addRecords(records.concat([fakeUser]))
    data = Ember.merge(paperPayload.toJSON(), action: "updated")

    Ember.run =>
      es.msgResponse(data)
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 2, "paper with no roles does not show on dashboard"

test 'When user is removed from collaborating on paper', ->
  visit '/'
  .then ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 2
  andThen ->
    # receives eventstream push to remove collaboration
    [es, store] = setupEventStream()
    paperPayload = Factory.createPayload('paper')
    records = paperWithRoles(1, [])
    paperPayload.addRecords(records.concat([fakeUser]))
    data = Ember.merge(paperPayload.toJSON(), action: "updated")

    Ember.run =>
      es.msgResponse(data)
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 1

test 'User can show the feedback form', ->
  visit '/'
  click '.navigation-toggle'
  click '.navigation-item-feedback'
  andThen ->
    ok find(".overlay-footer .button-primary:contains('Send Feedback')").length

test 'Hitting escape closes the feedback form', ->
  visit '/'
  click '.navigation-toggle'
  click '.navigation-item-feedback'
  keyEvent '.overlay', 'keyup', 27
  andThen ->
    ok !find(".overlay-footer .button-primary:contains('Send Feedback')").length

test 'User can show the feedback form', ->
  server.respondWith 'POST', "/feedback", [
    200, "Content-Type": "application/json", JSON.stringify {}
  ]

  visit '/'
  click '.navigation-toggle'
  click '.navigation-item-feedback'
  fillIn '.feedback-overlay-remarks', 'all my feedback'
  click '.overlay-footer .button-primary'
  andThen ->
    ok find(".feedback-overlay-thanks").length
    ok server.requests.findBy('url', '/feedback')
