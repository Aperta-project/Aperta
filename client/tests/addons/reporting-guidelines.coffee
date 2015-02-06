module 'Integration: Reporting Guidelines Card',
  teardown: ->
    ETahi.reset()
    ETahi.paperEditActionStub.restore()
  setup: ->
    setupApp integration: true
    TahiTest.questionId = 553

    questionResponse =
      question:
        _rootKey: "question"
        id: TahiTest.questionId
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
        id: TahiTest.questionId
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
      question_ids: [TahiTest.questionId]
    [paper, task, _, litePaper] = records

    paperPayload = ef.createPayload('paper')
    paperPayload.addRecords(records.concat(fakeUser, questionResponse.question))

    taskPayload = ef.createPayload('task')
    taskPayload.addRecords([task, litePaper])

    server.respondWith 'GET', "/papers/#{TahiTest.paperId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
    ]

    server.respondWith 'GET', "/tasks/#{TahiTest.reportingGuidelinesId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify taskPayload.toJSON()
    ]

    server.respondWith 'PUT', /\/questions\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify questionModifiedResponse
    ]

test 'Supporting Guideline is a meta data card, contains the right questions and sub-questions', ->
  findQuestionLi = (questionText) ->
    find('.question .item').filter (i, el) -> Em.$(el).find('label').text().trim() is questionText

  visit "/papers/#{TahiTest.paperId}/edit"
  .then ->
    ok exists find '.card-content:contains("Reporting Guidelines")'
    ETahi.paperEditActionStub = sinon.stub(ETahi.__container__.lookup('controller:paperEdit')._actions, "savePaper")

  click '.card-content:contains("Reporting Guidelines")'
  .then ->
    equal find('.question .item').length, 6
    equal find('h1').text(), 'Reporting Guidelines'
    questionLi = findQuestionLi 'Systematic Reviews'
    ok exists questionLi.find('.additional-data.hidden')

  click 'input[name="reporting_guidelines.systematic_reviews"]'
  .then ->
    questionLi = findQuestionLi 'Systematic Reviews'
    ok !(exists questionLi.find('.additional-data.hidden'))
    ok exists questionLi.find('.additional-data')
    additionalDataText = questionLi.find('.additional-data').first().text().trim()
    ok additionalDataText.indexOf('Select & upload') > -1
    ok additionalDataText.indexOf('Provide a completed PRISMA checklist as supporting information.') > -1
