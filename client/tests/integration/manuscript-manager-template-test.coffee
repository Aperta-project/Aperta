`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null

createJournalWithTaskTemplate = (taskType) ->
  journal = Factory.createRecord('Journal', id: 1, _rootKey: 'admin_journal')
  mmt = Factory.createMMT(journal, id: 1)
  pt = Factory.createPhaseTemplate(mmt, id: 1)
  jtt = Factory.createJournalTaskType(journal, taskType)
  [journal, mmt, pt, jtt]

module 'Integration: Manuscript Manager Templates',

  afterEach: ->
    server.restore()
    Ember.run(app, app.destroy)
    app.__container__.lookup(
      'controller:admin/journal/manuscript-manager-template/edit'
    )._actions.saveTemplateOnClick = app.saveTemplateActionFunction

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    app.saveTemplateActionFunction = app.__container__.lookup(
      'controller:admin/journal/manuscript-manager-template/edit'
    )._actions.saveTemplateOnClick

    app.__container__.lookup(
      'controller:admin/journal/manuscript-manager-template/edit'
    )._actions.saveTemplateOnClick = -> console.log 'No Action'

    records = createJournalWithTaskTemplate
      kind: "Task"
      title: "Ad Hoc"
      id: 1

    adminJournalPayload = Factory.createPayload('admin_journal')
    adminJournalPayload.addRecords(records)
    adminJournalResponse = adminJournalPayload.toJSON()
    admin = Factory.createRecord('User', siteAdmin: true)

    # let us see the manuscript template manager
    server.respondWith 'GET', /\/api\/flows\/authorization/, [
      204, 'Tahi-Authorization-Check': 'true', ""
    ]

    server.respondWith 'GET', "/api/admin/journals/1", [
      200, {"Content-Type": "application/json"}, JSON.stringify(adminJournalResponse)
    ]

    server.respondWith 'GET', "/api/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'GET', "/api/users/#{admin.id}", [
      200, 'Content-Type': 'application/json', JSON.stringify {user: admin}
    ]

    server.respondWith 'DELETE', "/api/task_templates/1", [
      204, "Content-Type": "application/json", JSON.stringify {}
    ]

    # related to "save templates" button
    server.respondWith 'PUT', "/api/manuscript_manager_templates/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]

    server.respondWith 'PUT', "/api/phase_templates/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]

    server.respondWith 'POST', "/api/manuscript_manager_templates/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]

    server.respondWith 'POST', "/api/phase_templates/1", [
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

    server.respondWith 'POST', "/api/task_templates", [
      200, {"Content-Type": "application/json"}, JSON.stringify(response)
    ]

test 'Changing phase name', (assert) ->
  columnTitleSelect = 'h2.column-title:contains("Phase 1")'
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
    .then ->
      assert.ok find(columnTitleSelect).length
  click columnTitleSelect
    .then -> Ember.$(columnTitleSelect).html('Shazam!')
  andThen ->
    assert.ok find('h2.column-title:contains("Shazam!")').length

test 'Adding an Ad-Hoc card', (assert) ->
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click('a.button--green:contains("Add New Card")')

  pickFromSelect2('.task-type-select', 'Ad Hoc')

  click('.overlay .button--green:contains("Add")').then ->
    assert.ok find('h1.inline-edit:contains("Ad Hoc")').length
    assert.ok(
      find('h1.inline-edit').hasClass('editing'),
      "The title should be editable to start"
    )

  click('.adhoc-content-toolbar .fa-plus')
  click('.adhoc-content-toolbar .adhoc-toolbar-item--text')

  andThen ->
    Ember.$('.inline-edit-form div[contenteditable]')
    .html("New contenteditable, yahoo!")
    .trigger('keyup')
    click('.task-body .inline-edit-body-part .button--green:contains("Save")')

  andThen ->
    assert.textPresent('.inline-edit', 'yahoo')
    click('.inline-edit-body-part .fa-trash')
  andThen ->
    assert.textPresent('.inline-edit-body-part', 'Are you sure?')
    click('.inline-edit-body-part .delete-button')
  andThen ->
    assert.textNotPresent('.inline-edit', 'yahoo')
    click('.overlay-close-button:first')

createCard = ->
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click('a.button--green:contains("Add New Card")')
  pickFromSelect2('.task-type-select', 'Ad Hoc')
  click '.button--green:contains("Add")'
    .then -> ok find('h1.inline-edit:contains("Ad Hoc")').length, 'It finds the ad hocs'
  andThen ->
    click '.overlay-close-button:first'

# see also paper_workflow_test.js.coffee; tests are very similar
test 'show delete confirmation overlay on deletion of a card', (assert) ->
  createCard()
  andThen ->
    click(".card-remove")
  andThen ->
    assert.equal find('.overlay button:contains("Yes, Delete this Card")').length, 1
    click find('.overlay button:contains("Yes, Delete this Card")')
  andThen ->
    assert.equal 0, find('.card-content').length

test 'click delete confirmation overlay cancel button', (assert) ->
  createCard()
  andThen ->
    equal find(".card-content").length, 1
    $(".card .card-remove").show()
    click(".card .card-remove")
    click('.overlay button:contains("cancel")')
    assert.equal find(".card-content").length, 1

test 'click delete confirmation overlay submit button', (assert) ->
  createCard()
  andThen ->
    # first POST to /task_templates
    click('.paper-type-save-button:contains("Save Template")')
  andThen ->
    equal find(".card-content").length, 1, "It finds the card content"
    $(".card .card-remove").show()
    click(".card .card-remove")
    # causes DELETE to /task_templates/1
    click('.overlay button:contains("Yes, Delete this Card")')
  andThen ->
    assert.equal find(".card-content").length, 0, "The card is gone"
  andThen ->
    search = { method: "DELETE", url: "/api/task_templates/1" }
    assert.ok _.findWhere(server.responses, search), "It sends DELETE request to the server"
