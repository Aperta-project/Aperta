`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

# TODO use server.respondWith
moduleFor 'controller:paper.edit.html-editor', 'PaperEditController',
  needs: ['controller:application', 'controller:paper']
  beforeEach: ->
    startApp()
    @phase1 = Ember.Object.create position: 1
    @phase2 = Ember.Object.create position: 2
    @phase3 = Ember.Object.create position: 3
    @phase4 = Ember.Object.create position: 4
    @paper = Ember.Object.create
      title: 'test paper'
      phases: [ ]

    sinon.stub(jQuery, "ajax")

  afterEach: ->
    jQuery.ajax.restore()

test '#exportDocument: calls the export url in Tahi', (assert) ->
  basePaperController = @subject()
  basePaperController.set('model', @paper)
  downloadType =
    url: "http://example.com"
    format: "docx"
  basePaperController.send 'exportDocument', downloadType
  assert.ok jQuery.ajax.calledWithMatch {url: "/api/papers/#{@paper.id}/export", data: {format: downloadType.format}}
