`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

moduleFor 'controller:paper/edit/html-editor', 'Unit: paper/edit/html-editor controller',
  needs: ['controller:application', 'controller:paper', 'controller:overlays/paperSubmit']

  beforeEach: ->
    startApp()
    currentUser = Ember.Object.create
      id: 1
      fullName: 'Pete Townshend'

    paper = Ember.Object.create
      id: 5
      title: ''
      shortTitle: 'Does not matter'
      body: 'hello'
      editable: true
      lockedBy: null
      editorType: 'html'

    @editor =
      fromHtml: sinon.stub()
      enable: sinon.stub()
      disable: sinon.stub()

    @subject().set 'model', paper
    @subject().set 'currentUser', currentUser
    @subject().set 'editor', @editor

test 'when the paper is being edited, do not update editor', ->
  @subject().set('model.lockedBy', @subject().get('currentUser'))
  @editor.fromHtml.reset()
  @subject().set('model.body', 'foo')

  ok !@editor.fromHtml.called, 'do not update editor'

test 'when the paper is not being edited, update editor on body change', ->
  @editor.fromHtml.reset()
  @subject().set('model.body', 'foo')

  ok @editor.fromHtml.called, 'update editor'
