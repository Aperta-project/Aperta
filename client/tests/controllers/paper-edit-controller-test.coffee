`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

moduleFor 'controller:paper/edit', 'Unit: paperEditController',
  needs: ['controller:application', 'controller:overlays/paperSubmit']

  setup: ->
    startApp()
    paper = Ember.Object.create
      id: 5
      title: ''
      shortTitle: 'Does not matter'
      body: 'hello'
      editable: true
    @editor =
      fromHtml: sinon.stub()

    @subject().set 'content', paper
    @subject().set 'editor', @editor

test 'when the paper is being edited, do not update editor on body change', ->
  @subject().set('isEditing', true)

  @editor.fromHtml.reset()
  @subject().set('body', 'foo')

  ok !@editor.fromHtml.called

test 'when the paper is not being edited, update editor on body change', ->
  @subject().set('isEditing', false)

  @editor.fromHtml.reset()
  @subject().set('body', 'foo')

  ok @editor.fromHtml.called
