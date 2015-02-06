`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

# TODO use server.respondWith
moduleFor 'controller:base-paper', 'BasePaperController',
  needs: ['controller:application']
  setup: ->
    startApp()
    @phase1 = Ember.Object.create position: 1
    @phase2 = Ember.Object.create position: 2
    @phase3 = Ember.Object.create position: 3
    @phase4 = Ember.Object.create position: 4
    @paper = Ember.Object.create
      title: 'test paper'
      phases: [ ]

    sinon.stub(jQuery, "ajax")

  teardown: ->
    jQuery.ajax.restore()

test '#export: calls the export url in Tahi', ->
  basePaperController = @subject()
  basePaperController.set('model', @paper)
  downloadType =
    url: "http://example.com"
    format: "docx"
  basePaperController.send 'export', downloadType
  ok jQuery.ajax.calledWithMatch {url: "/papers/#{@paper.id}/export", data: {format: downloadType.format}}
