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

  server.respondWith 'GET', "/admin/journals/authorized", [
    204, "Content-Type": "application/html", ""
  ]

respondUnauthorized = ->
  server.respondWith 'GET', '/admin/journals/authorized', [
    403, 'Content-Type': 'application/html', 'Tahi-Authorization-Check': true, ""
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

test '(admin=true) can see the Flow Manager link', ->
  respondUnauthorized()
  setCurrentUserAdmin(true)

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok exists(find ".navigation:contains('Flow Manager')")

test '(admin=false) cannot see the Flow Manager link', ->
  respondUnauthorized()
  setCurrentUserAdmin(false)

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

test '(403 response) cannot see the Admin link', ->
  respondUnauthorized()

  visit '/'
  click '.navigation-toggle'
  andThen ->
    ok !exists(find ".navigation:contains('Admin')")
