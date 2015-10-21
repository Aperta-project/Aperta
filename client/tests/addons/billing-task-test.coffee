`import Ember from "ember"`
`import { module, test } from "qunit"`
`import startApp from "../helpers/start-app"`
`import { paperWithTask, addUserAsParticipant, addNestedQuestionToTask } from "../helpers/setups"`
`import setupMockServer from "../helpers/mock-server"`
`import Factory from "../helpers/factory"`
`import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";`

app = null
server = null
fakeUser = null
currentPaper = null

module "Integration: Billing",
  afterEach: ->
    server.restore()
    Ember.run(-> TestHelper.teardown() )
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user
    TestHelper.handleFindAll("discussion-topic", 1)

    billingTaskId = 94139

    records = paperWithTask("BillingTask"
      id: billingTaskId
      role: "author"
    )

    [currentPaper, billingTask, journal, phase] = records

    paperPayload = Factory.createPayload("paper")
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()
    paperResponse.participations = [addUserAsParticipant(billingTask, fakeUser)]

    taskPayload = Factory.createPayload("task")

    nestedQuestions = [
      Factory.createRecord('NestedQuestion', { ident: 'first_name' })
      Factory.createRecord('NestedQuestion', { ident: 'last_name' })
      Factory.createRecord('NestedQuestion', { ident: 'title' })
      Factory.createRecord('NestedQuestion', { ident: 'first_name' })
      Factory.createRecord('NestedQuestion', { ident: 'last_name' })
      Factory.createRecord('NestedQuestion', { ident: 'title' })
      Factory.createRecord('NestedQuestion', { ident: 'department' })
      Factory.createRecord('NestedQuestion', { ident: 'phone_number' })
      Factory.createRecord('NestedQuestion', { ident: 'email' })
      Factory.createRecord('NestedQuestion', { ident: 'address1' })
      Factory.createRecord('NestedQuestion', { ident: 'address2' })
      Factory.createRecord('NestedQuestion', { ident: 'city' })
      Factory.createRecord('NestedQuestion', { ident: 'state' })
      Factory.createRecord('NestedQuestion', { ident: 'postal_code' })
      Factory.createRecord('NestedQuestion', { ident: 'country' })
      Factory.createRecord('NestedQuestion', { ident: 'payment_method' })
      Factory.createRecord('NestedQuestion', { ident: 'affiliation1' })
      Factory.createRecord('NestedQuestion', { ident: 'affiliation2' })
    ]

    for nestedQuestion in nestedQuestions
      addNestedQuestionToTask(nestedQuestion, billingTask)
      taskPayload.addRecord(nestedQuestion)
    paperResponse.nested_questions = nestedQuestions

    taskPayload.addRecords([billingTask, fakeUser])
    billingTaskResponse = taskPayload.toJSON()

    server.respondWith "GET", "/api/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith "GET", "/api/tasks/#{billingTaskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify billingTaskResponse
    ]
    server.respondWith "PUT", /\/api\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith "GET", /\/api\/filtered_users\/users\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

    $.mockjax({
      url: "/api/countries",
      status: 200,
      responseText: { "countries": ["California", "Ohio"] }
    })

test "Viewing card", (assert) ->
  visit "/papers/#{currentPaper.id}"
  click ".card-content:contains(Billing)"
  .then ->
    assert.equal find(".overlay-main-work h1").text().trim(), "Billing"
  click ".select2-choice"
  .then ->
    assert.ok Ember.$(".select2-result").length > 0
