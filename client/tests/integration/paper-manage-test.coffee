`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`
`import { paperWithParticipant } from '../helpers/setups'`
`import Factory from '../helpers/factory'`

app = null
server = null

module 'Integration: Paper Manage page',

  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()

    taskPayload =
      task:
        id: 1
        title: "New Ad-Hoc Task"
        type: "Task"
        phase_id: 1
        paper_id: 1
        lite_paper_id: 1

    # let us see the manuscript manager
    server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
      204, {}, ""
    ]

    server.respondWith 'GET', "/papers/1", [
      200, {"Content-Type": "application/json"}, JSON.stringify(paperWithParticipant().toJSON())
    ]

    server.respondWith 'POST', "/tasks", [
      200, {"Content-Type": "application/json"}, JSON.stringify(taskPayload)
    ]

    server.respondWith 'DELETE', "/tasks/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]

test 'show delete confirmation overlay on deletion of a Task', ->
  visit '/papers/1/manage'
  andThen ->
    $("div.card .card-remove").show()
    click("div.card .card-remove")
  andThen ->
    equal(find('h1:contains("You\'re about to delete this card forever")').length, 1)
    equal(find('h1:contains("Are you sure?")').length, 1)
    equal(find('.overlay button:contains("cancel")').length, 1)
    equal(find('.overlay button:contains("Yes, Delete this Card")').length, 1)

test 'click delete confirmation overlay cancel button', ->
  visit '/papers/1/manage'
  andThen ->
    equal find(".card-content").length, 1
    $("div.card .card-remove").show()
    click("div.card .card-remove")
    click('.overlay button:contains("cancel")')
    equal find(".card-content").length, 1

test 'click delete confirmation overlay submit button', ->
  visit '/papers/1/manage'
  andThen ->
    equal(find(".card-content").length, 1, "card exists")
    $("div.card .card-remove").show()
    click("div.card .card-remove")
    click('.overlay button:contains("Yes, Delete this Card")')
  andThen ->
    equal(find(".card-content").length, 0, "card deleted")
    req = _.findWhere(server.requests, {method: "DELETE", url: "/tasks/1"})
    equal(req.status, 200, "It sends DELETE request to the server")
