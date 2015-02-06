`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'controller:admin/journal/manuscript-manager-template/index', 'ManuscriptManagerTemplateIndexController',
  setup: ->
    startApp()
    Ember.run =>
      @ctrl = @subject()
      @store = getStore()
      @template = @store.createRecord 'manuscriptManagerTemplate', name: 'a template'
      @ctrl.setProperties
        model: [@template]
        store: @store

test '#destroyTemplate does not delete the last template', ->
  @ctrl.send 'destroyTemplate', @template
  equal(@ctrl.get('model.length'), 1)

test '#destroyTemplate deletes the given template when there are more than one templates', ->
  handler = ()->

  Ember.run =>
    @nextTemplate = @store.createRecord 'manuscriptManagerTemplate', name: 'next template'
    @ctrl.set 'model', [@template, @nextTemplate]
    sinon.stub(@nextTemplate, 'destroyRecord').returns(new Ember.RSVP.Promise(handler, handler))
    @ctrl.send 'destroyTemplate', @nextTemplate
    ok @nextTemplate.destroyRecord.called
