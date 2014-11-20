module 'Integration: Flow Manager Administration',
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
      can_view_flow_manager: false

    adminJournalPayload = ef.createPayload('adminJournal')
    adminJournalPayload.addRecords([journal, adminRole])

    server.respondWith 'GET', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalPayload.toJSON()
    ]

    server.respondWith 'GET', "/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'GET', '/user_flows/authorization', [
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
