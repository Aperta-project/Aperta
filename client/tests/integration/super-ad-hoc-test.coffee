`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`
`import { paperWithTask } from '../helpers/setups'`
`import Factory from '../helpers/factory'`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: Super AdHoc Card',

  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUser.user

    records = paperWithTask('Task'
      id: 1
      title: "Super Ad-Hoc"
    )
    currentPaper = records[0]

    paperPayload = Factory.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))

    paperResponse = paperPayload.toJSON()
    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/dashboards", [
      200, {"Content-Type": "application/json"}, JSON.stringify {dashboards: []}
    ]

    server.respondWith 'GET', "/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith 'GET', "/filtered_users/collaborators/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify collaborators
    ]
    server.respondWith 'GET', /\/filtered_users\/non_participants\/\d+\/\w+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

test "Changing the title on an AdHoc Task", ->
  visit "/papers/#{currentPaper.id}/tasks/1"
  click 'h1.inline-edit .glyphicon-pencil'
  fillIn '.large-edit input[name=title]', 'Shazam!'
  click '.large-edit .button--green:contains("Save")'
  andThen ->
    equal(find('h1.inline-edit:contains("Shazam!")').length, 1)

test "Adding a text block to an AdHoc Task", ->
  visit "/papers/#{currentPaper.id}/tasks/1"
  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--text'
  andThen ->
    Ember.$('.inline-edit-form div[contenteditable]')
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

test "Adding and removing a checkbox item to an AdHoc Task", ->
  visit "/papers/#{currentPaper.id}/tasks/1"

  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--list'
  andThen ->
    equal(find('.inline-edit-form .item-remove').length, 1)
    Ember.$('.inline-edit-form label[contenteditable]')
    .html("Here is a checkbox list item")
    .trigger('keyup')
    click '.task-body .inline-edit-body-part .button--green:contains("Save")'
  andThen ->
    assertText('.inline-edit', 'checkbox list item')
    equal(find('.inline-edit input[type=checkbox]').length, 1)
    click '.inline-edit-body-part .glyphicon-trash'
  andThen ->
    assertText('.inline-edit-body-part', 'Are you sure?')
    click '.inline-edit-body-part .delete-button'
  andThen ->
    assertNoText('.inline-edit', 'checkbox list item')

test "Adding an email block to an AdHoc Task", ->
  visit "/papers/#{currentPaper.id}/tasks/1"
  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--email'
  fillIn '.inline-edit-form input[placeholder="Enter a subject"]', "Deep subject"
  andThen ->
    Ember.$('.inline-edit-form div[contenteditable]').html("Awesome email body!").trigger('keyup')
    click '.task-body .inline-edit-body-part .button--green:contains("Save")'
  andThen ->
    assertText('.inline-edit .item-subject', 'Deep')
    assertText('.inline-edit .item-text', 'Awesome')


test "User can send an email from an adhoc card", ->
  server.respondWith 'PUT', /\/tasks\/\d+\/send_message/, [
    204, {"Content-Type": "application/json"}, JSON.stringify {}
  ]

  visit "/papers/#{currentPaper.id}/tasks/1"

  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--email'
  fillIn '.inline-edit-form input[placeholder="Enter a subject"]', "Deep subject"
  andThen ->
    Ember.$('.inline-edit-form div[contenteditable]').html("Awesome email body!").trigger('keyup')
    click '.task-body .inline-edit-body-part .button--green:contains("Save")'
  click '.task-body .email-send-participants'

  click('.send-email-action')

  andThen ->
    ok find('.bodypart-last-sent').length, 'The sent at time should appear'
    ok find('.bodypart-email-sent-overlay').length, 'The sent confirmation should appear'
    ok _.findWhere(server.requests, {method: "PUT", url: "/tasks/1/send_message"}), "It posts to the server"
