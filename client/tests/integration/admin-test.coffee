`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`
`import { paperWithParticipant } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null

module 'Integration: Admin Test',
  afterEach: ->
    server.restore()
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    journal = Factory.createRecord('AdminJournal')
    journalId = journal.id

    manuscript_manager_templates = Factory.createMMT(journal)
    phase_templates = Factory.createPhaseTemplate(manuscript_manager_templates)
    task_templates = Factory.createJournalTaskType(journal, {})
    journal_task_types = Factory.createTaskTemplate(journal, phase_templates, task_templates)
    oldRoles = Factory.createJournalOldRole(journal)
    admin_journals = journal

    adminJournalPayload = Factory.createPayload('adminJournal')
    adminJournalPayload.addRecords([
      manuscript_manager_templates,
      phase_templates,
      task_templates,
      journal_task_types,
      oldRoles,
      admin_journals
    ])

    server.respondWith 'GET', '/api/admin/journals/authorization', [
      204, 'Content-Type': 'application/html', ""
    ]

    server.respondWith 'GET', '/api/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/api/admin/journals/#{journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/api/journals", [
      200, 'Content-Type': 'application/json', JSON.stringify {journals:[]}
    ]

test 'site admin can see the Add New Journal button', (assert) ->
  visit("/admin/").then ->
    Ember.run =>
      getCurrentUser().set('siteAdmin', true)

  andThen ->
    assert.ok find('.journal-thumbnail').length, 'Journals visible'
    assert.ok find('.add-new-journal').length, 'Add New Journal button visible'

test 'journal admin can not see the Add New Journal button', (assert) ->
  visit "/admin/"
  andThen ->
    assert.ok find('.journal-thumbnail').length, 'Journals visible'
    assert.ok !find('.add-new-journal').length, 'Add New Journal button not visible'
