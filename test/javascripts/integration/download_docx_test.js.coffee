module 'Integration: Paper Docx Download',
  teardown: -> ETahi.reset()
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
    ETahi.supportedDownloadFormats = export_formats: [
      format: "docx"
      url: "https://tahi.example.com/export/docx"
      description: "This converts from docx to HTML"
    ]
    paperPayload = ef.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    server.respondWith 'GET', "/papers/#{ETahi.Test.currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

test 'show download links on control bar', ->
  visit "/papers/#{ETahi.Test.currentPaper.id}/edit"
  andThen ->
    equal find("div.downloads-link div.control-bar-link-icon").length, 1
    ok click("div.downloads-link div.control-bar-link-icon")
    equal find("div.manuscript-download-links.active").length, 1
    equal find('a.docx').length, 1
    click('a.docx')
