createJournalWithTaskTemplate = (taskType) ->
  ef = ETahi.Factory
  journal = ef.createRecord('Journal', id: 1, _rootKey: 'admin_journal')
  mmt = ef.createMMT(journal, id: 1)
  pt = ef.createPhaseTemplate(mmt, id: 1)
  [tt, jtt] = ef.createJournalTaskType(journal, taskType)
  [journal, mmt, pt, jtt, tt]

module 'Integration: Manuscript Manager Templates',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

test 'Changing phase name', ->
  ef = ETahi.Factory
  records = createJournalWithTaskTemplate
    kind: "Task"
    title: "Ad Hoc"
  adminJournalPayload = ef.createPayload()
  adminJournalPayload.addRecords(records)
  adminJournalsResponse = adminJournalPayload.toJSON()
  admin = ef.createRecord('User', admin: true)

  server.respondWith 'GET', "/admin/journals", [
    200, {"Content-Type": "application/json"}, JSON.stringify(adminJournalsResponse)
  ]

  server.respondWith 'GET', "/users/#{admin.id}", [
    200
    'Content-Type': 'application/json'
    JSON.stringify {user: admin}
  ]

  columnTitleSelect = 'h2.column-title:contains("Phase 1")'
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
    .then -> ok exists find columnTitleSelect

  click columnTitleSelect
    .then -> Em.$(columnTitleSelect).html('Shazam!')
  andThen ->
    ok exists find 'h2.column-title:contains("Shazam!")'

test 'Adding an Ad-Hoc card', ->
  ef = ETahi.Factory
  records = createJournalWithTaskTemplate
    kind: "Task"
    title: "Ad Hoc"
  adminJournalPayload = ef.createPayload()
  adminJournalPayload.addRecords(records)
  adminJournalsResponse = adminJournalPayload.toJSON()
  admin = ef.createRecord('User', admin: true)

  server.respondWith 'GET', "/admin/journals", [
    200, {"Content-Type": "application/json"}, JSON.stringify(adminJournalsResponse)
  ]

  server.respondWith 'GET', "/users/#{admin.id}", [
    200
    'Content-Type': 'application/json'
    JSON.stringify {user: admin}
  ]

  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click 'a.button--green:contains("Add New Card")'
    .then -> ok exists find '.chosen-container.task-type-select'
  pickFromChosenSingle '.task-type-select', 'Ad Hoc'
  click '.button--green:contains("Add")'
    .then -> ok exists find 'h1.inline-edit:contains("Ad Hoc")'
  click '.button--green.overlay-close-button'
  andThen ->
    ok exists find '.column .card-content:contains("Ad Hoc")'
