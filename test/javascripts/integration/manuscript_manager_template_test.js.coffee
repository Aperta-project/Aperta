createJournalWithTaskTemplate = (taskType) ->
  ef = ETahi.Factory
  journal = ef.createRecord('Journal', id: 1, _rootKey: 'admin_journal')
  mmt = ef.createMMT(journal, id: 1)
  pt = ef.createPhaseTemplate(mmt, id: 1)
  jtt = ef.createJournalTaskType(journal, taskType)
  [journal, mmt, pt, jtt]

module 'Integration: Manuscript Manager Templates',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)
    ef = ETahi.Factory
    records = createJournalWithTaskTemplate
      kind: "Task"
      title: "Ad Hoc"
      id: 1

    adminJournalPayload = ef.createPayload('admin_journal')
    adminJournalPayload.addRecords(records)
    adminJournalResponse = adminJournalPayload.toJSON()
    admin = ef.createRecord('User', siteAdmin: true)

    # let us see the manuscript template manager
    server.respondWith 'GET', /\/flows\/authorization/, [
      204
      'Tahi-Authorization-Check': 'true'
      ""
    ]

    server.respondWith 'GET', "/admin/journals/1", [
      200, {"Content-Type": "application/json"},
      JSON.stringify(adminJournalResponse)
    ]

    server.respondWith 'GET', "/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'GET', "/users/#{admin.id}", [
      200
      'Content-Type': 'application/json'
      JSON.stringify {user: admin}
    ]

    server.respondWith 'DELETE', "/task_templates/1", [
      204, "Content-Type": "application/json", JSON.stringify {}
    ]

    # related to "save templates" button
    server.respondWith 'PUT', "/manuscript_manager_templates/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]
    server.respondWith 'PUT', "/phase_templates/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]

    response = {
      "journal_task_types": [
        {
          "id": 1,
          "title": "Ad-hoc",
          "role": "user",
          "kind": "Task",
          "journal_id": 1
        }
      ],
      "task_template": {
        "id": 1,
        "template": [],
        "title": "Ad-hoc",
        "phase_template_id": 1,
        "journal_task_type_id": 1
      }
    }

    server.respondWith 'POST', "/task_templates", [
      200, {"Content-Type": "application/json"},
      JSON.stringify(response)
    ]

test 'Changing phase name', ->
  columnTitleSelect = 'h2.column-title:contains("Phase 1")'
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
    .then -> ok exists find columnTitleSelect

  click columnTitleSelect
    .then -> Em.$(columnTitleSelect).html('Shazam!')
  andThen ->
    ok exists find 'h2.column-title:contains("Shazam!")'

test 'Adding an Ad-Hoc card', ->
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click 'a.button--green:contains("Add New Card")'
  pickFromChosenSingle '.task-type-select', 'Ad Hoc'
  click '.button--green:contains("Add")'
    .then -> ok exists find 'h1.inline-edit:contains("Ad Hoc")'
  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--text'
  andThen ->
    ok(
      find('h1.inline-edit').hasClass('editing'),
      "The title should be editable to start"
    )
    Em.$('.inline-edit-form div[contenteditable]')
    .html("New contenteditable, yahoo!")
    .trigger('keyup')
    click '.task-body .inline-edit-body-part .button--green:contains("Save")'
  andThen ->
    assertText('.inline-edit', 'yahoo')
    click '.inline-edit-body-part .glyphicon-trash'
  andThen ->
    assertText('.inline-edit-body-part', 'Are you sure?')
    click '.inline-edit-body-part .delete-button'
  andThen ->
    assertNoText('.inline-edit', 'yahoo')
    click '.overlay-close-button:first'

createCard = ->
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click 'a.button--green:contains("Add New Card")'
  pickFromChosenSingle '.task-type-select', 'Ad Hoc'
  click '.button--green:contains("Add")'
    .then -> ok exists find 'h1.inline-edit:contains("Ad Hoc")'
  andThen ->
    click '.overlay-close-button:first'

# see also paper_manage_test.js.coffee; tests are very similar
test 'show delete confirmation overlay on deletion of a card', ->
  createCard()
  andThen ->
    click(".card-remove")
  andThen ->
    equal find('.overlay button:contains("Yes, Delete this Card")').length, 1
    click find('.overlay button:contains("Yes, Delete this Card")')
  andThen ->
    equal 0, find('.card-content').length

test 'click delete confirmation overlay cancel button', ->
  createCard()
  andThen ->
    equal find(".card-content").length, 1
    $("div.card .card-remove").show()
    click("div.card .card-remove")
    click('.overlay button:contains("cancel")')
    equal find(".card-content").length, 1

test 'click delete confirmation overlay submit button', ->
  createCard()
  andThen ->
    # first POST to /task_templates
    click find('.paper-type-save-button:contains("Save Template")')
  andThen ->
    equal find(".card-content").length, 1
    $("div.card .card-remove").show()
    click("div.card .card-remove")
    # causes DELETE to /task_templates/1
    click('.overlay button:contains("Yes, Delete this Card")')
  andThen ->
    equal find(".card-content").length, 0
  andThen ->
    search = { method: "DELETE", url: "/task_templates/1" }
    ok _.findWhere(server.requests, search),
      "It sends DELETE request to the server"
