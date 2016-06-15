`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import FactoryGuy from 'ember-data-factory-guy'`
`import TestHelper from "ember-data-factory-guy/factory-guy-test-helper"`

app = null

module 'Integration: Manuscript Manager Templates',

  beforeEach: ->
    Ember.run =>
      app = startApp()

      $.mockjax
        url: "/api/admin/journals/authorization"
        status: 204

      # used by the application controller to determine if a user
      # can see the paper tracker.  can be empty
      $.mockjax
        type: 'GET'
        url: "/api/journals"
        status: 200
        responseText:
          journals: []

  afterEach: ->
    $.mockjax.clear()
    Ember.run(app, 'destroy')

test 'Changing phase name', (assert) ->
  adminJournal = FactoryGuy.make('admin-journal', id: 1)
  mmt = FactoryGuy.make('manuscript-manager-template', id: 1, journal: adminJournal)
  pt = FactoryGuy.make('phase-template', id: 1, manuscriptManagerTemplate: mmt, name: "Phase 1")
  TestHelper.mockFind('admin-journal').returns(model: adminJournal)

  columnTitleSelect = 'h2.column-title:contains("Phase 1")'
  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click(columnTitleSelect).then ->
    Ember.$(columnTitleSelect).html('Shazam!')
  andThen ->
    assert.ok find('h2.column-title:contains("Shazam!")').length

test 'Adding an Ad-Hoc card', (assert) ->
  journalTaskType = FactoryGuy.make('journal-task-type',
    id: 1
    kind: "Task"
    title: "Ad Hoc"
  )
  adminJournal = FactoryGuy.make('admin-journal', id: 1, journalTaskTypes: [journalTaskType])
  mmt = FactoryGuy.make('manuscript-manager-template', id: 1, journal: adminJournal)
  pt = FactoryGuy.make('phase-template', id: 1, manuscriptManagerTemplate: mmt, name: "Phase 1")
  TestHelper.mockFind('admin-journal').returns(model: adminJournal)

  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click('.button--green:contains("Add New Card")')
  click('label:contains("Ad Hoc")')
  click('.overlay .button--green:contains("Add")')

  andThen ->
    assert.elementFound('h1.inline-edit:contains("Ad Hoc")')
    assert.ok(
      find('h1.inline-edit').hasClass('editing'),
      "The title should be editable to start"
    )

  # Add some new text to the card
  click('.adhoc-content-toolbar .fa-plus')
  click('.adhoc-content-toolbar .adhoc-toolbar-item--text')

  fillInContentEditable(
    '.inline-edit-form div[contenteditable]',
    'New contenteditable, yahoo!'
  )
  click('.task-body .inline-edit-body-part .button--green:contains("Save")')
  andThen ->
    assert.textPresent('.inline-edit', 'yahoo', 'text is still correct')

  click('.inline-edit-body-part .fa-trash')
  andThen ->
    assert.textPresent('.inline-edit-body-part', 'Are you sure?')
  click('.inline-edit-body-part .delete-button')
  andThen ->
    assert.textNotPresent('.inline-edit', 'yahoo', 'Deleted text is gone')

  click('.overlay-close-button')
  click('.card-content')
  andThen ->
    assert.elementFound('h1.inline-edit:contains("Ad Hoc")', 'User can edit the existing ad-hoc card')

test 'User cannot edit a non Ad-Hoc card', (assert) ->
  journalTaskType = FactoryGuy.make('journal-task-type',
    id: 1
    kind: "BillingTask"
    title: "Billing"
  )
  adminJournal = FactoryGuy.make('admin-journal', id: 1, journalTaskTypes: [journalTaskType])
  mmt = FactoryGuy.make('manuscript-manager-template', id: 1, journal: adminJournal)
  pt = FactoryGuy.make('phase-template', id: 1, manuscriptManagerTemplate: mmt, name: "Phase 1")
  TestHelper.mockFind('admin-journal').returns(model: adminJournal)

  visit("/admin/journals/1/manuscript_manager_templates/1/edit")
  click('.button--green:contains("Add New Card")')
  click('label:contains("Billing")')
  click('.overlay .button--green:contains("Add")')

  click('.card-content')
  andThen ->
    assert.elementNotFound('.ad-hoc-template-overlay', 'Clicking any other card has no effect')
