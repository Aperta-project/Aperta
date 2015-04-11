`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null
currentUserId = null
fakeUser = null
paperId = null
adminJournalId = null
adminRoleId = null
paperCount = null
pageCount = null

module 'Integration: Dashboard',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUser.user

    paperId = 934
    adminJournalId = 412
    adminRoleId = 98
    paperCount = 42
    pageCount = 3

    data =
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
      lite_papers: data.litePaper count: paperCount

    dashboardResponse =
      users: [fakeUser]
      affiliations: []
      lite_papers: litePapersResponse.lite_papers[0..14]
      dashboards: [
        id: 1
        user_id: 1
        paper_ids: [1..15]
        total_paper_count: paperCount
        total_page_count: pageCount
      ]

    adminJournalsResponse = {}

    server.respondWith 'GET', '/api/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify dashboardResponse
    ]

    server.respondWith 'GET', '/api/comment_looks', [
      200, 'Content-Type': 'application/json', JSON.stringify {comment_looks: []}
    ]

    server.respondWith 'GET', '/api/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
    ]

    server.respondWith 'GET', "/api/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    # end_index: (page number * 15) - 1
    # begin_index: end_index - 15
    server.respondWith 'GET', '/api/lite_papers?page_number=2', [
      200, 'Content-Type': 'application/json', JSON.stringify (lite_papers: litePapersResponse.lite_papers[15..29])
    ]

    server.respondWith 'GET', '/api/lite_papers?page_number=3', [
      200, 'Content-Type': 'application/json', JSON.stringify (lite_papers: litePapersResponse.lite_papers[30..paperCount - 1])
    ]

test 'With more than 15 papers, there should be a "Load More" button if we are not at the last page', ->
  visit '/'
  .then ->
    ok find('.load-more-papers').length
    ok !Ember.isEmpty find('.welcome-message').text().match(/You have 42 manuscripts/)
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 15
  click '.load-more-papers'
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 30
    ok find('.load-more-papers').length
  click '.load-more-papers'
  andThen ->
    equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 42
    ok !find('.load-more-papers').length
