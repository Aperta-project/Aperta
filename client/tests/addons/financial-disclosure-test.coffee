`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask, addUserAsParticipant } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';`


app = null
server = null
fakeUser = null
currentPaper = null
financialDisclosureTaskId = 94139
financialDisclosureTask = null
paperPayload = null

module 'Integration: FinancialDisclosure',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)
  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user
    TestHelper.handleFindAll('discussion-topic', 1)

    records = paperWithTask('FinancialDisclosureTask'
      id: financialDisclosureTaskId
      role: "author"
    )

    [currentPaper, financialDisclosureTask, journal, phase] = records

    paperPayload = Factory.createPayload('paper')

    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()
    paperResponse.participations = [addUserAsParticipant(financialDisclosureTask, fakeUser)]

    taskPayload = Factory.createPayload('task')
    taskPayload.addRecords([financialDisclosureTask, fakeUser])
    financialDisclosureTask = taskPayload.toJSON()

    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/api/tasks/#{financialDisclosureTaskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify financialDisclosureTask
    ]
    server.respondWith 'PUT', /\/api\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith 'GET', /\/api\/filtered_users\/users\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

    server.respondWith 'POST', '/api/questions', [
      204, {"Content-Type": "application/json"}, JSON.stringify []
    ]

    server.respondWith 'DELETE', /\/api\/funders\/\d+/, [
      204, {"Content-Type": "application/html"}, ""
    ]


    mirrorCreateResponse = (key, newId) ->
      (xhr) ->
        createdItem = JSON.parse(xhr.requestBody)
        createdItem[key].id = newId
        response = JSON.stringify createdItem
        xhr.respond(201,{"Content-Type": "application/json"}, response)

    server.respondWith 'POST', "/api/funders", mirrorCreateResponse('funder', 1)

test 'Viewing the card and adding new funder', (assert) ->
  visit "/papers/#{currentPaper.id}/tasks/#{financialDisclosureTaskId}"
  .then ->
    assert.equal find('.overlay-main-work h1').text().trim(), 'Financial Disclosures'
    assert.ok find("label:contains('Yes')").length
    click "label:contains('Yes')"
    andThen ->
      assert.ok find("button:contains('Add Another Funder')").length, "User can add another funder"
      assert.ok find("span.remove-funder").length, "User can add remove the funder"
      Ember.$('[name="funder-name"]').val("Hello")
      Ember.$('[name="grant-number"]').val("1234567890")
      click("label:contains('Completed')")

test "Removing an existing funder when there's only 1", (assert) ->
  visit "/papers/#{currentPaper.id}/tasks/#{financialDisclosureTaskId}"
  click "label:contains('Yes')"
  click "span.remove-funder"

  andThen ->
    assert.ok !find('input#received-funding-no:checked').length, "Returned to netual"
    assert.ok !find('input#received-funding-yes:checked').length, "Returned to netual"
