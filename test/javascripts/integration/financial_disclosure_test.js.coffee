module 'Integration: Financial Disclosure', ->
  teardown: -> ETahi.reset()
  setup: ->

test "Viewing the card", ->
  records = ETahi.Setups.paperWithTask ('FinancialDisclosureTask')
  payload = ETahi.Factory.createPayload('paper')
  payload.addRecords(records)

  server.respondWith 'GET', "/papers/1", [
    200, {"Content-Type": "application/json"}, JSON.stringify payload.toJSON()
  ]

  visit '/papers/1/tasks/1'
  andThen ->
    ok find('.question').length
