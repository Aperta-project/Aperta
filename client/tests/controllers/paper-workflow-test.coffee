`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'controller:paper/workflow', 'PaperWorkflowController',
  needs: ['controller:application']
  beforeEach: ->
    @phase1 = Ember.Object.create position: 1
    @phase2 = Ember.Object.create position: 2
    @phase3 = Ember.Object.create position: 3
    @phase4 = Ember.Object.create position: 4
    @paper = Ember.Object.create
      title: 'test paper'
      phases: [ ]

test '#sortedPhases: phases are sorted by position', (assert) ->
  paperWorkflowController = @subject()
  paperWorkflowController.set('model', @paper)
  paperWorkflowController.set 'model.phases', [ @phase3, @phase2, @phase4 ]

  sortedPositionArray = paperWorkflowController.get('sortedPhases').mapBy('position').toArray()
  assert.deepEqual sortedPositionArray, [ 2, 3, 4 ]

  paperWorkflowController.get('model.phases').pushObject @phase1
  sortedPositionArray = paperWorkflowController.get('sortedPhases').mapBy('position').toArray()
  assert.deepEqual sortedPositionArray, [ 1, 2, 3, 4 ]

test '#updatePositions: phase positions are updated accordingly', (assert) ->
  assert.equal @phase3.get('position'), 3
  assert.equal @phase4.get('position'), 4

  paperWorkflowController = @subject()
  paperWorkflowController.set('model', @paper)
  paperWorkflowController.set 'model.phases', [ @phase1, @phase2, @phase3, @phase4 ]
  @phase1.setProperties position: 3
  paperWorkflowController.updatePositions @phase1

  assert.equal @phase3.get('position'), 4
  assert.equal @phase4.get('position'), 5
