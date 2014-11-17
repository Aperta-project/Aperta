module 'Integration: Admin Journal Test',

  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true
    TahiTest.journalId = 209
    TahiTest.editorRoleId = 8
    TahiTest.reviewerRoleId = 9

    journalRoles =
      [
        id: 7
        kind: "admin"
        name: "Admin"
        required: true
        can_administer_journal: true
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: true
        can_view_flow_manager: true
        journal_id: TahiTest.journalId
      ,
        id: TahiTest.editorRoleId
        kind: "editor"
        name: "Editor"
        required: true
        can_administer_journal: false
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: false
        can_view_flow_manager: false
        journal_id: TahiTest.journalId
      ,
        id: TahiTest.reviewerRoleId
        kind: "reviewer"
        name: "Reviewer"
        required: true
        can_administer_journal: false
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: false
        can_view_flow_manager: false
        journal_id: TahiTest.journalId
      ,
        id: TahiTest.reviewerRoleId
        kind: "flow manager"
        name: "Flow Manager"
        required: true
        can_administer_journal: false
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: false
        can_view_flow_manager: true
        journal_id: TahiTest.journalId
      ]

    adminJournal =
      id: TahiTest.journalId
      name: "Test Journal of America"
      logo_url: "foo"
      paper_types: ["Research"]
      task_types: [ "FinancialDisclosure::Task" ]
      description: "This is a test journal"
      paper_count: 3
      created_at: "2014-06-16T22:23:16.320Z"
      manuscript_manager_templates: [
        id: 5
        paper_type: "Research"
        template: {}
        journal_id: TahiTest.journalId
      ]
      role_ids: [7, TahiTest.editorRoleId, TahiTest.reviewerRoleId]
      doi_publisher_prefix: undefined
      doi_journal_prefix: undefined
      doi_start_number: undefined

    adminJournalPayload =
      roles: journalRoles
      admin_journal: adminJournal

    adminJournalsPayload =
      roles: journalRoles
      admin_journals: [adminJournal]

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

    server.respondWith 'GET', "/admin/journals", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalsPayload
    ]

    server.respondWith 'PUT', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'GET', "/admin/journal_users?journal_id=#{TahiTest.journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalUserResponse
    ]

    server.respondWith 'GET', "/admin/journal_users?query=#{TahiTest.query}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalUserResponse
    ]

    admin_journal_users = "/admin/journal_users"
    query = "?query=#{TahiTest.query}&journal_id=#{TahiTest.journalId}"
    server.respondWith 'GET', admin_journal_users + query, [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalUserResponse
    ]

    server.respondWith 'POST', "/user_roles", [
      201, "Content-Type": "application/json", JSON.stringify userRoleResponse
    ]

    server.respondWith 'DELETE', "/user_roles/#{TahiTest.userRoleId}", [
      204, "Content-Type": "application/json", JSON.stringify {}
    ]

test 'admin sees the complete DOI form', ->
  # assert that the admin page has the 3 fields
  visit "/admin/journals/#{TahiTest.journalId}"
  .then ->
    ok find('.admin-doi-setting-section')
    ok find('.admin-doi-setting-section .doi_publisher_prefix')
    ok find('.admin-doi-setting-section .doi_journal_prefix')
    ok find('.admin-doi-setting-section .doi_start_number')

test 'admin can set DOI doi_publisher_prefix, doi_journal_prefix, doi_start_number', ->
  PPREFIX = "PPREFIX"
  JPREFIX = "JPREFIX"
  doi_start_number = "10000"
  adminPage = "/admin/journals/#{TahiTest.journalId}"
  visit adminPage
  .then ->
    ok find('.admin-doi-setting-section .doi_publisher_prefix').val(PPREFIX)
    ok find('.admin-doi-setting-section .doi_journal_prefix').val(JPREFIX)
    ok find('.admin-doi-setting-section .doi_start_number').val(doi_start_number)
    button = find('.admin-doi-setting-section button')
    ok button
    click button
  andThen ->
    url = "/admin/journals/#{TahiTest.journalId}"
    ok _.findWhere(server.requests, { method: 'PUT', url })

  visit adminPage
  .then ->
    equal(find('.admin-doi-setting-section .doi_publisher_prefix').val(), PPREFIX)
    equal(find('.admin-doi-setting-section .doi_journal_prefix').val(), JPREFIX)
    equal(find('.admin-doi-setting-section .doi_start_number').val(), doi_start_number)
