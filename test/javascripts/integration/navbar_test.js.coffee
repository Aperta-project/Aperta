module 'Integration: Navbar',
  teardown: -> ETahi.reset()

  setup: ->
    setupApp integration: true

    TahiTest.dashboardResponse =
      dashboards: [
        id: 1
      ]

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify TahiTest.dashboardResponse
    ]

respondAuthorized = ->
  adminJournalsResponse =
    admin_journals: [
      id: 1
      name: "Test Journal of America"
    ]

  server.respondWith 'GET', '/admin/journals', [
    200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
  ]

  server.respondWith 'GET', "/admin/journals/authorization", [
    204, "Content-Type": "application/html", ""
  ]

  server.respondWith 'GET', '/flows/authorization', [
    204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]

respondUnauthorized = ->
  server.respondWith 'GET', '/admin/journals/authorization', [
    403, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]

  server.respondWith 'GET', '/flows/authorization', [
    403, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]

setCurrentUserAdmin = (bool) ->
  store = ETahi.__container__.lookup 'store:main'
  store.find 'user', currentUserId
  .then (currentUser) -> currentUser.set 'admin', bool

test 'all users can see their username', ->
  respondUnauthorized()
  setCurrentUserAdmin(false)

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok exists(find ".navigation-item-account span:contains('Fake User')")

test '(200 response) can see the Flow Manager link', ->
  respondAuthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok exists(find ".navigation:contains('Flow Manager')")

test '(403 response) cannot see the Flow Manager link', ->
  respondUnauthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok !exists(find ".navigation:contains('Flow Manager')")

test '(200 response) can see the Admin link', ->
  respondAuthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok exists(find ".navigation:contains('Admin')")

test '(200 response) can see the Flow Manager link', ->
  respondAuthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok exists(find ".navigation:contains('Flow Manager')")

test '(403 response) cannot see the Admin link', ->
  respondUnauthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok !exists(find ".navigation:contains('Admin')")

test '(403 response) cannot see the Flow Manager link', ->
  respondUnauthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok !exists(find ".navigation:contains('Flow Manager')")
