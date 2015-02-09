`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import VisualEditorService from 'tahi/services/visual-editor'`

moduleFor 'view:paper/edit', 'Unit: paperEditView',
  teardown: ->
    VisualEditorService.create.restore()

  setup: ->

    startApp()
    paper = Ember.Object.create
      id: 5
      title: ''
      shortTitle: 'Does not matter'
      body: 'hello'
      editable: true

    sinon.stub(VisualEditorService, 'create').returns
      enable: ->
      disable: ->

    controller = getContainer().lookup 'controller:paper.edit'

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
