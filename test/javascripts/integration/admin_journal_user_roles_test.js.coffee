module 'Integration: Admin Journal User Roles, /admin/journals/:id',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true

    ef = ETahi.Factory
    journal = ef.createRecord('AdminJournal')
    TahiTest.journalId = journal.id

    adminRole = ef.createJournalRole journal,
      name: "Admin"
      kind: "admin"
      can_administer_journal: true
      can_view_assigned_manuscript_managers: false
      can_view_all_manuscript_managers: true
      can_view_flow_manager: true

    editorRole = ef.createJournalRole journal,
      name: "Editor"
      kind: "editor"
      can_administer_journal: false
      can_view_assigned_manuscript_managers: false
      can_view_all_manuscript_managers: false
      can_view_flow_manager: false
    TahiTest.editorRoleId = editorRole.id

    reviewerRole = ef.createJournalRole journal,
      name: "Reviewer"
      kind: "reviewer"
      can_administer_journal: false
      can_view_assigned_manuscript_managers: false
      can_view_all_manuscript_managers: false
      can_view_flow_manager: false
    TahiTest.reviewerRoleId = reviewerRole.id

    adminJournalPayload = ef.createPayload('adminJournal')
    adminJournalPayload.addRecords([journal, adminRole, editorRole, reviewerRole])

    TahiTest.userRoleId = 99
    TahiTest.adminUserId = 923
    userRoleResponse =
      user_role:
        id: TahiTest.userRoleId
        user_id: TahiTest.adminUserId
        role_id: TahiTest.editorRoleId

    adminJournalUserResponse =
      user_roles: [
        id: TahiTest.userRoleId
        user_id: TahiTest.adminUserId
        role_id: TahiTest.reviewerRoleId
      ]
      admin_journal_users: [
        id: TahiTest.adminUserId
        username: "fakeuser"
        first_name: "Fake"
        last_name: "User"
        info: "Test String"
        user_role_ids: [TahiTest.userRoleId]
      ]

    TahiTest.query = 'User'

    server.respondWith 'GET', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalPayload.toJSON()
    ]

    server.respondWith 'GET', "/admin/journal_users?journal_id=#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalUserResponse
    ]

    server.respondWith 'GET', "/admin/journal_users?query=#{TahiTest.query}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalUserResponse
    ]

    server.respondWith 'GET', "/admin/journal_users?query=#{TahiTest.query}&journal_id=#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalUserResponse
    ]

    server.respondWith 'POST', "/user_roles", [
      201, "Content-Type": "application/json", JSON.stringify userRoleResponse
    ]

    server.respondWith 'DELETE', "/user_roles/#{TahiTest.userRoleId}", [
      204, "Content-Type": "application/json", JSON.stringify {}
    ]

test 'admin adds a role for user', ->
  visit "/admin/journals/#{TahiTest.journalId}"
  .then -> ok exists 'tr.user-row'
  fillIn '.admin-user-search-input', TahiTest.query
  click '.admin-user-search-button'
  click '.assign-role-button'
  .then -> $('.add-role-input').val('Edit').trigger('input')
  .then -> click '.tt-suggestion'
  andThen -> assertText('.assigned-role', 'Editor')

test 'admin removes a role for user', ->
  visit "/admin/journals/#{TahiTest.journalId}"
  fillIn '.admin-user-search-input', TahiTest.query
  click '.admin-user-search-button'
  .then ->
    ok exists '.assigned-role.token'
    click '.token-remove'
  andThen -> ok !exists '.assigned-role.token'

test 'autocomplete does not give roles the user is already assigned to', ->
  visit "/admin/journals/#{TahiTest.journalId}"
  fillIn '.admin-user-search-input', TahiTest.query
  click '.admin-user-search-button'
  click '.assign-role-button'
  .then -> $('.add-role-input').typeahead 'val', 'Edit'
  .then -> click '.tt-suggestion'
  click '.assign-role-button'
  .then -> $('.add-role-input').typeahead 'val', 'Edit'
  andThen -> ok !exists '.tt-suggestion'
