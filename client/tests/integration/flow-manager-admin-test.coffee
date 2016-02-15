`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null
fakeUser = null
journal = null

module 'Integration: Flow Manager Administration',

  afterEach: ->
    server.restore()
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    journal = Factory.createRecord('AdminJournal')

    adminRole = Factory.createJournalOldRole journal,
      name: "Admin"
      kind: "admin"
      can_administer_journal: true
      can_view_assigned_manuscript_managers: false
      can_view_all_manuscript_managers: true
      can_view_flow_manager: false

    adminJournalPayload = Factory.createPayload('adminJournal')
    adminJournalPayload.addRecords([journal, adminRole])

    server.respondWith 'GET', "/api/admin/journals/#{journal.id}", [
      200, "Content-Type": "application/json", JSON.stringify(adminJournalPayload.toJSON())
    ]

    server.respondWith 'GET', "/api/admin/journals/authorization", [
      204, "Content-Type": "application/html", ""
    ]

    server.respondWith 'GET', '/api/user_flows/authorization', [
      204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
    ]

    server.respondWith 'GET', "/api/admin/journal_users?journal_id=#{journal.id}", [
      200, "Content-Type": "application/json", JSON.stringify { admin_journal_users: [] }
    ]

    server.respondWith 'GET', "/api/flows?old_role_id=#{adminRole.id}", [
      200, 'content-type': 'application/json', JSON.stringify({ flows: [] })
    ]

    server.respondWith 'GET', "/api/journals", [
      200, {'Content-Type': 'application/json'}, JSON.stringify({journals:[]})
    ]

test 'Flow manager edit link should show up on a oldRole with permission in edit mode', (assert) ->
  visit "/admin/journals/#{journal.id}"
  click('.admin-role-action-button.fa.fa-pencil')
  andThen ->
    assert.ok !find('a:contains("Edit Flows")').length, "No flow manager link should show up without permission"
  click('input[name="role[canViewFlowManager]"]')
  andThen ->
    assert.ok find('a:contains("Edit Flows")').length, "three"

test "Admin can add a new column in a oldRole's flow-manager", (assert) ->
  visit "/admin/journals/#{journal.id}"
  click '.admin-role-action-button.fa.fa-pencil'
  click 'input[name="role[canViewFlowManager]"]'
  click 'a:contains("Edit Flows")'
  andThen ->
    assert.ok find('.back-link').text().match(/Flow Manager/), "one"
    assert.ok find('.control-bar-link-text:contains("Add New Column")'), "two"
  # click '.add-flow-column-button'
