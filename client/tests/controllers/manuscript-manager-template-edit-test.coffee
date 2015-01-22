`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'controller:admin/journal/manuscript-manager-template/edit', 'ManuscriptManagerTemplateEditController',
  setup: ->
    startApp()

    Ember.run =>
      @ctrl = @subject()
      @store = getStore()
      @phase = @store.createRecord 'phaseTemplate', name: 'First Phase'
      @task1 = @store.createRecord 'taskTemplate', title: 'ATask', phaseTemplate: @phase
      @task2 = @store.createRecord 'taskTemplate', title: 'BTask', phaseTemplate: @phase

      @template = @store.createRecord 'manuscriptManagerTemplate',
        name: 'A name'
        paper_type: 'A type'
        phases: [@phase]

      @ctrl.setProperties
        model: @template
        store: @store

test '#rollbackPhase sets the given old name on the given phase', ->
  phase = Ember.Object.create name: "Captain Picard"
  @ctrl.send 'rollbackPhase', phase, "Captain Kirk"
  equal(phase.get('name'), "Captain Kirk")

test '#addPhase adds a phase at a specified index', ->
  Em.run =>
    @ctrl.send 'addPhase', 0
    equal @ctrl.get('sortedPhaseTemplates.firstObject.name'), 'New Phase'

test "#removeTask removes the given task from the template's phase", ->
  Ember.run =>
    @ctrl.send 'removeTask', @task1
    tasks = @phase.get('taskTemplates')
    deepEqual tasks.mapBy('title'), ['BTask']
