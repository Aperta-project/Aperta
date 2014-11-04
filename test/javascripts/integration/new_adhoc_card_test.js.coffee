module 'Integration: adding an adhoc card',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true

    taskPayload =
      task:
        id: 2
        title: "New Ad-Hoc Task"
        type: "Task"
        phase_id: 1
        paper_id: 1
        lite_paper_id: 1

    #let us see the manuscript manager
    server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
      204
      'Tahi-Authorization-Check': 'true'
      ""
    ]

    server.respondWith 'GET', "/papers/1", [
      200, {"Content-Type": "application/json"}, JSON.stringify ETahi.Setups.paperWithParticipant().toJSON()
    ]

    server.respondWith 'POST', "/tasks", [
      200, {"Content-Type": "application/json"}, JSON.stringify taskPayload
    ]

test 'user should be editing title when adhoc card is created', ->
  visit '/papers/1/manage'
  click("a:contains('Add New Card')")
  click("#choose-card-type-buttons .task")
  andThen ->
    ok find('.inline-edit-form').hasClass('editing')
