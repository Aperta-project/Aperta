moduleFor 'view:paperEdit', 'Unit: paperEditView',
  teardown: ->
    ETahi.VisualEditorService.create.restore()
    ETahi.reset()

  setup: ->
    paper = Ember.Object.create
      title: ''
      shortTitle: 'Does not matter'
      body: 'hello'

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
