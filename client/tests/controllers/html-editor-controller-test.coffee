`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

moduleFor 'controller:paper/index/html-editor', 'HTMLEditorController',
  needs: ['controller:application', 'controller:paper', 'controller:overlays/paper-submit']

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
      enable: sinon.stub()
      disable: sinon.stub()
      update: sinon.stub()

    @subject().set 'model', paper
    @subject().set 'currentUser', currentUser
    @subject().set 'editor', @editor

test 'update editor on body change', (assert) ->
  @editor.update.reset()
  @subject().set('model.body', 'foo')

  assert.ok @editor.update.called, 'update editor'
