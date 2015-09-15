`import Ember from "ember"`
`import { module, test } from "qunit"`
`import startApp from "../helpers/start-app"`
`import { paperWithTask, addUserAsParticipant } from "../helpers/setups"`
`import setupMockServer from "../helpers/mock-server"`
`import Factory from "../helpers/factory"`
`import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: Reporting Guidelines Card',
  afterEach: ->
    server.restore()
    Ember.run(-> TestHelper.teardown() )
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user
    TestHelper.handleFindAll("discussion-topic", 1)

    questionId = 553
    taskId = 94139

    questionResponse =
      question:
        _rootKey: "question"
        id: questionId
        ident: "reporting_guidelines.systematic_reviews"
        question: "Systematic Reviews"
        answer: "false"
        additional_data: [{}]
        task_id: taskId
        question_attachment_id: null
      question_attachments: []

    # we have to change the answer to true on click
    questionModifiedResponse =
      question:
        id: questionId
        ident: "reporting_guidelines.systematic_reviews"
        question: "Systematic Reviews"
        answer: "true"
        additional_data: [{}]
        task_id: taskId
        question_attachment_id: null
      question_attachments: []

    records = paperWithTask("ReportingGuidelinesTask",
      id: taskId
      role: "author"
      question_ids: [questionId]
    )

    [currentPaper, task, _] = records

    paperPayload = Factory.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser, questionResponse.question]))
    paperResponse = paperPayload.toJSON()
    paperResponse.participations = [addUserAsParticipant(task, fakeUser)]

    taskPayload = Factory.createPayload('task')
    taskPayload.addRecords([task, fakeUser])
    taskResponse = taskPayload.toJSON()

    server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/api/tasks/#{taskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify taskResponse
    ]
    server.respondWith 'PUT', /\/api\/questions\/\d+/, [
     200, {"Content-Type": "application/json"}, JSON.stringify questionModifiedResponse
    ]

test 'Supporting Guideline is a meta data card, contains the right questions and sub-questions', (assert) ->
  findQuestionLi = (questionText) ->
    find('.question .item').filter (i, el) -> Ember.$(el).find('label').text().trim() is questionText

  visit "/papers/#{currentPaper.id}"
  .then ->
    assert.ok find('#paper-metadata-tasks .card-content:contains("Reporting Guidelines")')

  click '.card-content:contains("Reporting Guidelines")'
  .then ->
    assert.equal find('.question .item').length, 6
    assert.equal find('h1').text(), 'Reporting Guidelines'
    questionLi = findQuestionLi 'Systematic Reviews'
    assert.ok questionLi.find('.additional-data.hidden')

  click 'input[name="reporting_guidelines.systematic_reviews"]'
  .then ->
    questionLi = findQuestionLi 'Systematic Reviews'
    assert.equal(0, questionLi.find('.additional-data.hidden').length)
    assert.ok questionLi.find('.additional-data')
    additionalDataText = questionLi.find('.additional-data').first().text().trim()
    assert.ok additionalDataText.indexOf('Select & upload') > -1
    assert.ok additionalDataText.indexOf('Provide a completed PRISMA checklist as supporting information.') > -1
