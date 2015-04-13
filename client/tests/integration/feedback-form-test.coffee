`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`

app = null
server = null
fakeUser = null

module 'Integration: Feedback Form',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUser.user

    dashboardResponse =
      users: [fakeUser]
      dashboards: [
        id: 1
        user_id: 1
        paper_ids: []
        total_paper_count: 1
        total_page_count: 1
      ]

    server.respondWith 'GET', '/api/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify dashboardResponse
    ]

    server.respondWith 'GET', "/api/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'POST', "/api/feedback", [
      201, "Content-Type": "application/json", "{}"
    ]

test 'clicking the feedback button sends feedback to the backend', ->
  visit '/'

  .then ->
    click '.navigation-toggle'
  .andThen ->
    click '.navigation-item-feedback'
    ok find('.overlay').length
  .andThen ->
    fillIn '.overlay textarea', "My feedback"
    click '.overlay-footer-content .button-primary'
  .andThen ->
    ok find('.overlay .thanks')
