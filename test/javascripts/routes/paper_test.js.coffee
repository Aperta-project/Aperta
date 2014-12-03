controller = undefined
moduleFor 'route:paper', 'Unit: route/Paper',
  needs: ['model:paper', 'route:paper'],
  teardown: -> ETahi.reset()
  setup: ->
    setupApp()
    @subject().store = find: sinon.stub()

    props = {}
    controller =
      set: (key, value) -> props[key] = value
      get: (key) -> props[key]
    window.ETahi.supportedDownloadFormats = {
      "export_formats":[{ "format": "docx"}, { "format": "latex" }],
      "import_formats":[{ "format": "docx"}, { "format": "odt" }]
    }

test 'the model should be paper', ->
  @subject().model paper_id: 123
  ok @subject().store.find.calledWith 'paper', 123

test 'supportedDownloadFormats: returns array with injected icon partial paths', ->
  @subject().setupController(controller, @subject().model)
  formats = controller.get('supportedDownloadFormats')
  equal formats[0].icon, 'svg/docx-icon'
