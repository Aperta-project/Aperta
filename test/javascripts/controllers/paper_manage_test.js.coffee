moduleFor 'controller:paperManage', 'PaperManageController',
  needs: ['controller:application']
  setup: ->
    setupApp()
    @phase1 = Ember.Object.create position: 1
    @phase2 = Ember.Object.create position: 2
    @phase3 = Ember.Object.create position: 3
    @phase4 = Ember.Object.create position: 4
    @paper = Ember.Object.create
      title: 'test paper'
      phases: [ ]

test '#sortedPhases: phases are sorted by position', ->
  paperManageController = @subject()
  paperManageController.set('model', @paper)
  paperManageController.set 'model.phases', [ @phase3, @phase2, @phase4 ]

  sortedPositionArray = paperManageController.get('sortedPhases').mapBy('position').toArray()
  deepEqual sortedPositionArray, [ 2, 3, 4 ]

  paperManageController.get('model.phases').pushObject @phase1
  sortedPositionArray = paperManageController.get('sortedPhases').mapBy('position').toArray()
  deepEqual sortedPositionArray, [ 1, 2, 3, 4 ]

test '#updatePositions: phase positions are updated accordingly', ->
  equal @phase3.get('position'), 3
  equal @phase4.get('position'), 4

  paperManageController = @subject()
  paperManageController.set('model', @paper)
  paperManageController.set 'model.phases', [ @phase1, @phase2, @phase3, @phase4 ]
  @phase1.setProperties position: 3
  paperManageController.updatePositions @phase1

  equal @phase3.get('position'), 4
  equal @phase4.get('position'), 5
