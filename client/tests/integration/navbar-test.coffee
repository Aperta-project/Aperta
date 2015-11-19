`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';`

app = null
server = null

module 'Integration: Navbar',

  afterEach: ->
    server.restore()
    Ember.run(app, app.destroy)
    Ember.run ->
      TestHelper.teardown()

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    TestHelper.handleFindAll('paper', 0)
    TestHelper.handleFindAll('invitation', 0)

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

test 'all users can see their username', (assert) ->
  respondUnauthorized()

  visit('/').then ->
    setCurrentUserAdmin(false)

  andThen ->
    equal(find("#profile-dropdown-menu:contains('Fake User')").length, 1)

test '(200 response) can see the Flow Manager link', (assert) ->
  respondAuthorized()

  visit '/'
  andThen ->
    equal(find(".main-nav:contains('Flow Manager')").length, 1)

test '(403 response) cannot see the Flow Manager link', (assert) ->
  respondUnauthorized()

  visit '/'
  andThen ->
    equal(find(".main-nav:contains('Flow Manager')").length, 0)

test '(200 response) can see the Admin link', (assert) ->
  respondAuthorized()

  visit '/'
  andThen ->
    equal(find(".main-nav:contains('Admin')").length, 1)

test '(403 response) cannot see the Admin link', (assert) ->
  respondUnauthorized()

  visit '/'
  andThen ->
    equal(find(".main-nav:contains('Admin')").length, 0)

test '(403 response) cannot see the Flow Manager link', (assert) ->
  respondUnauthorized()

  visit '/'
  andThen ->
    equal(find(".main-nav:contains('Flow Manager')").length, 0)
