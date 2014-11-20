module 'Integration: Admin Journal Test',

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

    adminJournalPayload = ef.createPayload('adminJournal')
    adminJournalPayload.addRecords([journal, adminRole])

    stubbedAdminJournalUserResponse =
      user_roles: []
      admin_journal_users: []

    server.respondWith 'PUT', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalPayload.toJSON()
    ]

    server.respondWith 'GET', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/admin/journal_users?journal_id=#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify stubbedAdminJournalUserResponse
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
