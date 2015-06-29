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
      enable: sinon.stub()
      disable: sinon.stub()
      update: sinon.stub()

    @subject().set 'model', paper
    @subject().set 'currentUser', currentUser
    @subject().set 'editor', @editor

test 'update editor on body change', ->
  @editor.update.reset()
  @subject().set('model.body', 'foo')

  ok @editor.update.called, 'update editor'
