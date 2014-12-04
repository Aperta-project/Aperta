url = undefined
jobId = undefined
workingReponse = undefined
completeReponse = undefined
statusUrl = undefined
expectedSupportedDownloadFormats = undefined
module 'Integration: Paper Docx Download',
  teardown: ->
    ETahi.reset()

  setup: ->
    setupApp integration: true
    ef = ETahi.Factory

    records = ETahi.Setups.paperWithTask('Task'
      id: 1
      title: "Metadata"
      isMetadataTask: true
      completed: true
    )
    ETahi.Test = {}
    ETahi.Test.currentPaper = records[0]
    paperPayload = ef.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    server.respondWith 'GET', "/papers/#{ETahi.Test.currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

    jobId = '232134-324-1234-1234'
    result = { jobs: { id: "#{jobId}" } }
    url = "/papers/#{ETahi.Test.currentPaper.id}/export?format=docx"
    server.respondWith 'GET', url, [
      200, {"Content-Type": "application/json"}, JSON.stringify result
    ]

    completeResult = {
      "jobs": {
        "status": "complete",
        "id": "#{jobId}",
        "url": 'https://www.google.com'
      }
    }

    statusUrl = "/papers/#{ETahi.Test.currentPaper.id}/status/#{jobId}"

    returnResponse = (response) ->
      server.respondWith('GET',
       statusUrl,
       [200, {"Content-Type": "application/json"}, JSON.stringify response])

    returnResponse(completeResult)

test 'show download links on control bar', ->
  called = 0
  args = undefined
  mock = undefined
  visit "/papers/#{ETahi.Test.currentPaper.id}/edit"
  andThen ->
    mock = sinon.mock(Tahi.utils)
    mock.expects("windowLocation").withArgs("https://www.google.com")
      .returns(true)

    equal find("div.downloads-link div.control-bar-link-icon").length, 1
    ok click("div.downloads-link div.control-bar-link-icon")
    equal find("div.manuscript-download-links.active").length, 1
    equal find('a.docx').length, 1
    equal find('a.docx').attr('title'), 'Download docx'
    click('a.docx')
  andThen ->
    ok _.findWhere(server.requests, { method: 'GET', url })
    mock.restore()

test 'iHat supported formats are set after page load', ->
  visit "/papers/#{ETahi.Test.currentPaper.id}/edit"
  andThen ->
    # Expected formats are set in mock_server.js so that other tests don't 404
    # on /formats when someone visits the paper_edit_route or paper_index_route.
    # The mock_server.js has a route for /formats that is always defined.
    export_formats = window.ETahi.supportedDownloadFormats.export_formats
    expected = window.expectedSupportedDownloadFormats
    equal(export_formats[0].format, expected.export_formats[0].format)
    equal(export_formats[1].format, expected.export_formats[1].format)

    import_formats = window.ETahi.supportedDownloadFormats.import_formats
    equal(import_formats[0].format, expected.import_formats[0].format)
    equal(import_formats[1].format, expected.import_formats[1].format)
