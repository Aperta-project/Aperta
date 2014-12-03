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

    # for the formats test
    expectedSupportedDownloadFormats = {
        "import_formats": [
          {
            "format": "docx",
            "url": "https://tahi.example.com/import/docx",
            "description": "This converts from HTML to Office Open XML"
          },
          {
            "format": "odt",
            "url": "https://tahi.example.com/import/odt",
            "description": "This converts from HTML to ODT"
          }
        ],
        "export_formats": [
          {
            "format": "docx",
            "url": "https://tahi.example.com/export/docx",
            "description": "This converts from docx to HTML"
          },
          {
            "format": "latex",
            "url": "https://tahi.example.com/export/latex",
            "description": "This converts from latex to HTML"
          }
        ]
      }
    server.respondWith 'GET', '/formats', [
      200,
      {"Content-Type": "application/json"},
      JSON.stringify expectedSupportedDownloadFormats
    ]

test 'show download links on control bar', ->
  called = 0
  args = undefined
  mock = undefined
  visit "/papers/#{ETahi.Test.currentPaper.id}/edit"
  andThen ->
    mock = sinon.mock(Tahi.utils)
    mock.expects("windowLocation").withArgs("https://www.google.com").returns(true)

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
    deepEqual(
      window.ETahi.supportedDownloadFormats, expectedSupportedDownloadFormats
    )
