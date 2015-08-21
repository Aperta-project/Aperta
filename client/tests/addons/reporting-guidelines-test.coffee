`import Ember from 'ember'`
`import { module, test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

app = null
questionId = 553

module 'Integration: Reporting Guidelines Card',
  afterEach: ->
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()

    questionResponse =
      question:
        _rootKey: "question"
        id: questionId
        ident: "reporting_guidelines.systematic_reviews"
        question: "Systematic Reviews"
        answer: "false"
        additional_data: [{}]
        task_id: TahiTest.reportingGuidelinesId
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
        task_id: TahiTest.reportingGuidelinesId
        question_attachment_id: null
      question_attachments: []

    ef = ETahi.Factory
    records = ETahi.Setups.paperWithTask "ReportingGuidelinesTask",
      id: TahiTest.reportingGuidelinesId
      question_ids: [questionId]
    [paper, task, _] = records

    paperPayload = ef.createPayload('paper')
    paperPayload.addRecords(records.concat(fakeUser, questionResponse.question))

    taskPayload = ef.createPayload('task')
    taskPayload.addRecords([task])

    server.respondWith 'GET', "/papers/#{TahiTest.paperId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
    ]

    server.respondWith 'GET', "/tasks/#{TahiTest.reportingGuidelinesId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify taskPayload.toJSON()
    ]

    server.respondWith 'PUT', /\/questions\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify questionModifiedResponse
    ]

test 'Supporting Guideline is a meta data card, contains the right questions and sub-questions', (assert) ->
  assert.ok false
  findQuestionLi = (questionText) ->
    find('.question .item').filter (i, el) -> Ember.$(el).find('label').text().trim() is questionText

  visit "/papers/#{TahiTest.paperId}"
  .then ->
    assert.ok exists find '.card-content:contains("Reporting Guidelines")'
    ETahi.paperEditActionStub = sinon.stub(ETahi.__container__.lookup('controller:paperEdit')._actions, "savePaper")

  click '.card-content:contains("Reporting Guidelines")'
  .then ->
    assert.equal find('.question .item').length, 6
    assert.equal find('h1').text(), 'Reporting Guidelines'
    questionLi = findQuestionLi 'Systematic Reviews'
    assert.ok exists questionLi.find('.additional-data.hidden')

  click 'input[name="reporting_guidelines.systematic_reviews"]'
  .then ->
    questionLi = findQuestionLi 'Systematic Reviews'
    assert.ok !(exists questionLi.find('.additional-data.hidden'))
    assert.ok exists questionLi.find('.additional-data')
    additionalDataText = questionLi.find('.additional-data').first().text().trim()
    assert.ok additionalDataText.indexOf('Select & upload') > -1
    assert.ok additionalDataText.indexOf('Provide a completed PRISMA checklist as supporting information.') > -1
