module 'Integration: PaperIndex',
  teardown: ->
    ETahi.reset()

  setup: ->
    setupApp(integration: true)

test 'on paper.index, contributors are visible', ->
  ef = ETahi.Factory
  records = ETahi.Setups.paperWithTask('Task'
    id: 2
    role: "admin"
  )

  paperPayload = ef.createPayload('paper')

  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()
  paperResponse.paper.submitted = true

  server.respondWith 'GET', "/papers/#{records[0].id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit "/papers/#{records[0].id}"
  andThen ->
    Ember.run ->
      getStore().getById('paper', records[0].id).set('editable', false)
  andThen ->
    click('.contributors-link')
    # using JQuery to select an element (the navbar) outside the QUnit container
    equal $("html.control-bar-sub-nav-active").length, 1
    equal $(".control-bar-sub-items .contributors.active").is(':visible'), 1
