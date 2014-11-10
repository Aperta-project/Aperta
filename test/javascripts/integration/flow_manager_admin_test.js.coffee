module 'Integration: Flow Manager Administration',
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
        can_view_flow_manager: false
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
      manuscript_manager_templates: []
      role_ids: [7]

    adminJournalPayload =
      roles: journalRoles
      admin_journal: adminJournal

    TahiTest.userRoleId = 99
    TahiTest.adminUserId = 923

    server.respondWith 'GET', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'GET', "/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'GET', '/flows/authorization', [
      204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
    ]

    server.respondWith 'GET', "/admin/journal_users?journal_id=#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify { admin_journal_users: [] }
    ]

test 'Flow manager edit link should show up on a role with permission in edit mode', ->
  visit "/admin/journals/#{TahiTest.journalId}"
  click('.admin-role-action-button')
  andThen ->
    ok !exists('a:contains("Edit Flows")'), "No flow manager link should show up without permission"
  click('input[name="role[canViewFlowManager]"]')
  andThen ->
    ok exists('a:contains("Edit Flows")')
