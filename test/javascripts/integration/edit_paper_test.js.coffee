module 'Integration: EditPaper',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)
    ef = ETahi.Factory

    figureTaskId = 94139

    records = ETahi.Setups.paperWithTask('FigureTask'
      id: figureTaskId
      role: "author"
    )

    ETahi.Test = {}
    [ETahi.Test.currentPaper, ETahi.Test.figureTask, ETahi.Test.journal, ETahi.Test.litePaper, ETahi.Test.phase] = records

    paperPayload = ef.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    taskPayload = ef.createPayload('task')
    taskPayload.addRecords([ETahi.Test.figureTask, ETahi.Test.litePaper, fakeUser])
    figureTaskResponse = taskPayload.toJSON()

    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/papers/#{ETahi.Test.currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/tasks/#{figureTaskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify figureTaskResponse
    ]
    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith 'GET', /\/filtered_users\/users\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

test 'visiting /edit-paper: Author completes all metadata cards', ->
  visit "/papers/#{ETahi.Test.currentPaper.id}/edit"
  .then -> ok find('a:contains("Submit")').hasClass 'button--disabled'
  .then ->
    for card in find('#paper-metadata-tasks .card-content')
      click card
      click '#task_completed'
      click '.overlay-close-button:first'
  .then -> ok !find('a:contains("Submit")').hasClass 'button--disabled'

test 'on paper.edit when paper.editable changes, user transitions to paper.index', ->
  visit "/papers/#{ETahi.Test.currentPaper.id}/edit"
  .then ->
    Ember.run ->
      getStore().getById('paper', ETahi.Test.currentPaper.id).set('editable', false)
  andThen ->
    ok !exists find('.button-primary:contains("Submit")')
    equal currentRouteName(), "paper.index"

test 'on paper.edit when there are no metadata tasks', ->
  expect(2)
  ef = ETahi.Factory
  records = ETahi.Setups.paperWithTask('Task'
    id: 2
    role: "admin"
  )

  paperPayload = ef.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()

  server.respondWith 'GET', "/papers/#{records[0].id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit "/papers/#{records[0].id}/edit"
  .then -> ok exists find('main.sidebar-empty'), "The sidebar should be hidden"
  .then -> ok exists find('.edit-paper .no-sidebar-submit-manuscript.button--green:contains("Submit Manuscript")'), "There is a submit manuscript button in the main area"

test 'on paper.index when there are no metadata tasks', ->
  expect(2)
  ef = ETahi.Factory
  records = ETahi.Setups.paperWithTask('Task'
    id: 2
    role: "admin"
  )

  paperPayload = ef.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()

  server.respondWith 'GET', "/papers/#{records[0].id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit "/papers/#{records[0].id}/edit"
  .then ->
    Ember.run ->
      getStore().getById('paper', records[0].id).set('editable', false)
  andThen ->
    ok exists find('main.sidebar-empty'), "The sidebar should be hidden"
    ok !exists find('.edit-paper .no-sidebar-submit-manuscript.button--green:contains("Submit Manuscript")'), "There is no submit manuscript button in the main area"
