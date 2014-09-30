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

respondUnauthorized = ->
  server.respondWith 'GET', '/admin/journals', [
    403, 'Content-Type': 'application/html', 'Tahi-Authorization-Check': true, ""
  ]

setCurrentUserAdmin = (bool) ->
  store = ETahi.__container__.lookup 'store:main'
  store.find 'user', window.currentUserId
  .then (currentUser) -> currentUser.set 'admin', bool

test 'all users can see their username', ->
  respondUnauthorized()
  setCurrentUserAdmin(false)

  visit '/'
  .then ->
    click '.navigation-toggle'
    .then ->
      ok $('.navigation-item-account:first').text().indexOf(@fakeUser.full_name) isnt -1

test '(admin=true) can see the Flow Manager link', ->
  respondUnauthorized()
  setCurrentUserAdmin(true)

  visit '/'
  .then ->
    click '.navigation-toggle'
    .then ->
      ok $('.navigation').text().indexOf('Flow Manager') isnt -1

test '(admin=false) cannot see the Flow Manager link', ->
  respondUnauthorized()
  setCurrentUserAdmin(false)

  visit '/'
  .then ->
    click '.navigation-toggle'
    .then ->
      ok $('.navigation').text().indexOf('Flow Manager') is -1

test '(200 response) can see the Admin link', ->
  respondAuthorized()

  visit '/'
  .then ->
    click '.navigation-toggle'
    .then ->
      ok $('.navigation').text().indexOf('Admin') isnt -1

test '(403 response) cannot see the Admin link', ->
  respondUnauthorized()

  visit '/'
  .then ->
    click '.navigation-toggle'
    .then ->
      ok $('.navigation').text().indexOf('Admin') is -1
