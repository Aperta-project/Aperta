module 'Integration: Paper Manage page',
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

    # let us see the manuscript manager
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

    server.respondWith 'DELETE', "/tasks/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]

test 'show delete confirmation overlay on deletion of a Task', ->
  visit '/papers/1/manage'
  andThen ->
    $("div.card .card-remove").show()
    click("div.card .card-remove")
  andThen ->
    ok find('h1').first().text().indexOf("You're about to delete this card forever") > 0
    ok find('h1').last().text().indexOf("Are you sure?") > 0
    equal find('.overlay button:contains("cancel")').length, 1
    equal find('.overlay button:contains("Yes, Delete this Card")').length, 1

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
    equal find(".card-content").length, 1
    $("div.card .card-remove").show()
    click("div.card .card-remove")
    click('.overlay button:contains("Yes, Delete this Card")')
  andThen ->
    equal find(".card-content").length, 0
    ok _.findWhere(server.requests, {method: "DELETE", url: "/tasks/1"}), "It sends DELETE request to the server"
