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

  beforeEach: ->
    Ember.run =>
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

      server.respondWith 'GET', "/api/journals", [
        200, {'Content-Type': 'application/json'}, JSON.stringify({journals:[]})
      ]

      response = {
        "journal_task_types": [
          {
            "id": 1,
            "title": "Ad-hoc",
            "old_role": "user",
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

  afterEach: ->
    server.restore()
    Ember.run(app, 'destroy')
    app.__container__.lookup(
      'controller:admin/journal/manuscript-manager-template/edit'
    )._actions.saveTemplateOnClick = app.saveTemplateActionFunction

test 'Changing phase name', (assert) ->
  columnTitleSelect = 'h2.column-title:contains("Phase 1")'
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click(columnTitleSelect).then ->
    Ember.$(columnTitleSelect).html('Shazam!')
  andThen ->
    assert.ok find('h2.column-title:contains("Shazam!")').length

test 'Adding an Ad-Hoc card', (assert) ->
  Ember.run =>
    visit("/admin/journals/1/manuscript_manager_templates/1/edit").then ->
      click('.button--green:contains("Add New Card")')
      click('label:contains("Ad Hoc")')
      andThen ->
        Ember.run ->
          click('.overlay .button--green:contains("Add")')

      andThen ->
        assert.ok find('h1.inline-edit:contains("Ad Hoc")').length
        assert.ok(
          find('h1.inline-edit').hasClass('editing'),
          "The title should be editable to start"
        )

      click('.adhoc-content-toolbar .fa-plus')
      click('.adhoc-content-toolbar .adhoc-toolbar-item--text')

      andThen ->
        Ember.run =>
          Ember.$('.inline-edit-form div[contenteditable]')
          .html("New contenteditable, yahoo!")
          .trigger('keyup')
      andThen ->
        Ember.run ->
          click('.task-body .inline-edit-body-part .button--green:contains("Save")')

      andThen ->
        assert.textPresent('.inline-edit', 'yahoo')
        click('.inline-edit-body-part .fa-trash')
      andThen ->
        assert.textPresent('.inline-edit-body-part', 'Are you sure?')
      andThen ->
        Ember.run ->
          click('.inline-edit-body-part .delete-button')
      andThen ->
        assert.textNotPresent('.inline-edit', 'yahoo')
        click('.overlay-close-button:first')
