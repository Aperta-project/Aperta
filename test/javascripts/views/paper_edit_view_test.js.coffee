moduleFor 'view:paperEdit', 'Unit: paperEditView',
  teardown: ->
    ETahi.VisualEditorService.create.restore()
    ETahi.reset()

  setup: ->
    ETahi.supportedDownloadFormats = JSON.parse '{"import_formats":[{"format":"docx","url":"https://tahi.example.com/import/docx","description":"This converts from HTML to Office Open XML"},{"format":"odt","url":"https://tahi.example.com/import/odt","description":"This converts from HTML to ODT"}],"export_formats":[{"format":"docx","url":"https://tahi.example.com/export/docx","description":"This converts from docx to HTML"},{"format":"latex","url":"https://tahi.example.com/export/latex","description":"This converts from latex to HTML"}]}'
    paper = Ember.Object.create
      id: 5
      title: ''
      shortTitle: 'Does not matter'
      body: 'hello'
      editable: true

    sinon.stub(ETahi.VisualEditorService, 'create').returns
      enable: ->
      disable: ->

    controller = ETahi.__container__.lookup 'controller:paperEdit'

    @subject().set 'controller', controller
    controller.set 'content', paper

    sinon.stub @subject(), 'updateVisualEditor'
    @subject().setupVisualEditor()

test 'when the paper is being edited, do not update editor on body change', ->
  @subject().set('isEditing', true)

  @subject().updateVisualEditor.reset()
  @subject().set('controller.body', 'foo')

  ok !@subject().updateVisualEditor.called

test 'when the paper is not being edited, update editor on body change', ->
  @subject().set('isEditing', false)

  @subject().updateVisualEditor.reset()
  @subject().set('controller.body', 'foo')

  ok @subject().updateVisualEditor.called
