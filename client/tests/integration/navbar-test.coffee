`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null

module 'Integration: Navbar',

  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()

    dashboardResponse = dashboards: [ id: 1 ]

    server.respondWith 'GET', '/api/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify(dashboardResponse)
    ]

respondAuthorized = ->
  adminJournalsResponse =
    admin_journals: [
      id: 1
      name: "Test Journal of America"
    ]

  server.respondWith 'GET', '/api/admin/journals', [
    200, 'Content-Type': 'application/json', JSON.stringify(adminJournalsResponse)
  ]

  server.respondWith 'GET', "/api/admin/journals/authorization", [
    204, "Content-Type": "application/html", ""
  ]

  server.respondWith 'GET', '/api/user_flows/authorization', [
    204, 'content-type': 'application/html', ""
  ]

respondUnauthorized = ->
  server.respondWith 'GET', '/api/admin/journals/authorization', [
    403, 'content-type': 'application/html', ""
  ]

  server.respondWith 'GET', '/api/user_flows/authorization', [
    403, 'content-type': 'application/html', ""
  ]

setCurrentUserAdmin = (bool) ->
  store = getStore()
  store.find 'user', getCurrentUser().get('id')
  .then (currentUser) -> currentUser.set 'admin', bool

test 'all users can see their username', ->
  respondUnauthorized()
  setCurrentUserAdmin(false)

  visit '/'
  click '.navigation-toggle'
  andThen ->
    equal(find(".navigation-item--account span:contains('Fake User')").length, 1)

test '(200 response) can see the Flow Manager link', ->
  respondAuthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    equal(find(".navigation:contains('Flow Manager')").length, 1)

test '(403 response) cannot see the Flow Manager link', ->
  respondUnauthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    equal(find(".navigation:contains('Flow Manager')").length, 0)

test '(200 response) can see the Admin link', ->
  respondAuthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    equal(find(".navigation:contains('Admin')").length, 1)

test '(200 response) can see the Flow Manager link', ->
  respondAuthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    equal(find(".navigation:contains('Flow Manager')").length, 1)

test '(403 response) cannot see the Admin link', ->
  respondUnauthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    equal(find(".navigation:contains('Admin')").length, 0)

test '(403 response) cannot see the Flow Manager link', ->
  respondUnauthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    equal(find(".navigation:contains('Flow Manager')").length, 0)
