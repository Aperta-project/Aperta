`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`
`import { paperWithParticipant } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null

module 'Integration: Admin Test',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    journal = Factory.createRecord('AdminJournal')
    journalId = journal.id

    manuscript_manager_templates = Factory.createMMT(journal)
    phase_templates = Factory.createPhaseTemplate(manuscript_manager_templates)
    task_templates = Factory.createJournalTaskType(journal, {})
    journal_task_types = Factory.createTaskTemplate(journal, phase_templates, task_templates)
    roles = Factory.createJournalRole(journal)
    admin_journals = journal

    adminJournalPayload = Factory.createPayload('adminJournal')
    adminJournalPayload.addRecords([
      manuscript_manager_templates,
      phase_templates,
      task_templates,
      journal_task_types,
      roles,
      admin_journals
    ])

    server.respondWith 'GET', '/admin/journals/authorization', [
      204, 'Content-Type': 'application/html', ""
    ]

    server.respondWith 'GET', '/admin/journals', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalPayload
    ]

    server.respondWith 'GET', "/admin/journals/#{journalId}", [
      200, "Content-Type": "application/json",
      JSON.stringify adminJournalPayload
    ]

test 'site admin can see the Add New Journal button', ->
  Ember.run =>
    getCurrentUser().set('siteAdmin', true)

  visit("/admin/")

  andThen ->
    ok find('.journal').length
    ok find('a.add-new-journal').length

test 'journal admin can not see the Add New Journal button', ->
  visit "/admin/"
  andThen ->
    ok find('.journal').length
    ok !find('a.add-new-journal').length
