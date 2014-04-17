#= require test_helper

moduleFor 'controller:manuscriptManagerTemplateEdit', 'ManuscriptManagerTemplateEditController',
  setup: ->
    task1 = Ember.Object.create title: 'ATask', isMessage: false
    task2 = Ember.Object.create title: 'BTask', isMessage: false

    @phase = name: 'First Phase', tasks: [task1, task2], position: 1
    @template = Ember.Object.create
      name: 'A name'
      paper_type: 'A type'
      template:
        phases: [@phase]
    Ember.run =>
      @ctrl = @subject()
      @ctrl.set 'model', @template

test '#rollbackPhase sets the given old name on the given phase', ->
  phase = Ember.Object.create name: "Captain Picard"
  @ctrl.send 'rollbackPhase', phase, "Captain Kirk"
  equal(phase.get('name'), "Captain Kirk")

test '#addPhase adds a phase at a specified position', ->
  @ctrl.send 'addPhase', 1
  equal @ctrl.get('sortedPhases.firstObject.name'), 'New Phase'

