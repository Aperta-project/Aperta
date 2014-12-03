module 'Integration: Admin Test',

  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true

    ef = ETahi.Factory
    journal = ef.createRecord('AdminJournal')
    TahiTest.journalId = journal.id

    manuscript_manager_templates = ef.createMMT(journal)
    phase_templates = ef.createPhaseTemplate(manuscript_manager_templates)
    task_templates = ef.createJournalTaskType(journal, {})
    journal_task_types = ef.createTaskTemplate(journal, phase_templates, task_templates)
    roles = ef.createJournalRole(journal)
    admin_journals = journal

    adminJournalPayload = ef.createPayload('adminJournal')
    adminJournalPayload.addRecords([
      manuscript_manager_templates,
      phase_templates,
      task_templates,
      journal_task_types,
      roles,
      admin_journals
    ])

    server.respondWith 'GET', '/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/admin/journals/#{TahiTest.journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalPayload
    ]

test 'site admin can see the Add New Journal button', ->
  visit "/admin/"
  .then ->
    currentUser = ETahi.__container__.lookup('store:main').find('user', @currentUserId)
    .then (user) ->
      user.set('siteAdmin', true)
  .then ->
    visit "/admin/"
    .then ->
      ok find('.journal').length
      ok find('a.add-new-journal').length

test 'journal admin can not see the Add New Journal button', ->
  visit "/admin/"
  .then ->
    ok find('.journal').length
    ok !find('a.add-new-journal').length
