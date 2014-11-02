module 'Integration: Financial Disclosure', ->
  teardown: ->  ETahi.reset()

test "Viewing the card", ->
  ef = ETahi.Factory
  records = ETahi.Setups.paperWithTask ('FinancialDisclosureTask')
  paper = records[0]
  author = ef.createAuthor(paper, first_name: "Bob", last_name: "Dole")
  payload = ef.createPayload('paper')
  payload.addRecords(records)
  payload.addRecords([author])

  server.respondWith 'GET', "/papers/1", [
    200, {"Content-Type": "application/json"}, JSON.stringify payload.toJSON()
  ]

  mirrorCreateResponse = (key, newId) ->
    (xhr) ->
      createdItem = JSON.parse(xhr.requestBody)
      createdItem[key].id = newId
      response = JSON.stringify createdItem
      xhr.respond(201,{"Content-Type": "application/json"}, response)

  server.respondWith 'POST', "/funders", mirrorCreateResponse('funder', 1)

  visit '/papers/1/tasks/1'
  click "input#received-funding-yes"
  click ".chosen-author input"
  click "li.active-result:contains('Bob Dole')"
  andThen ->
    ok _.findWhere(server.requests, {method: "POST", url: "/funders"}), "It posts to the server"
    ok find("button:contains('Add Another Funder')").length, "User can add another funder"
    ok find("a.remove-funder-link").length, "User can add remove the funder"

test "Removing an existing funder when there's only 1", ->
  ef = ETahi.Factory
  records = ETahi.Setups.paperWithTask ('FinancialDisclosureTask')
  paper = records[0]
  task = records[1]
  author = ef.createAuthor(paper)
  funder = ef.createRecord('Funder', author_ids: [author.id], task_id: task.id, id: 1)
  task.funder_ids = [1]
  payload = ef.createPayload('paper')
  payload.addRecords(records.concat([author, funder]))

  server.respondWith 'GET', "/papers/1", [
    200, {"Content-Type": "application/json"}, JSON.stringify payload.toJSON()
  ]

  server.respondWith 'DELETE', "/funders/1", [
    204, {"Content-Type": "application/html"}, ""
  ]

  visit '/papers/1/tasks/1'
  click "a.remove-funder-link"
  andThen ->
    ok _.findWhere(server.requests, {method: "DELETE", url: "/funders/1"}), "It posts to the server to delete the funder"
    ok find('input#received-funding-no:checked').length, "Received funding is set to 'no'"
