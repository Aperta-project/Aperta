`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

moduleFor 'view:paper/edit', 'Unit: paperEditView',

  setup: ->

    startApp()
    paper = Ember.Object.create
      id: 5
      title: ''
      shortTitle: 'Does not matter'
      body: 'hello'
      editable: true

    controller = getContainer().lookup 'controller:paper.edit'

    @subject().set 'controller', controller
    controller.set 'content', paper

    sinon.stub @subject(), 'updateEditor'
    @subject().setupEditor()

test 'when the paper is being edited, do not update editor on body change', ->
  @subject().set('isEditing', true)

  @subject().updateEditor.reset()
  @subject().set('controller.body', 'foo')

  ok !@subject().updateEditor.called

test 'when the paper is not being edited, update editor on body change', ->
  @subject().set('isEditing', false)

  @subject().updateEditor.reset()
  @subject().set('controller.body', 'foo')

  ok @subject().updateEditor.called
