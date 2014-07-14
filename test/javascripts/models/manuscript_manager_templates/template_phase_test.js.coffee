testTasks = undefined
testPhase = undefined
newPhase = undefined

module 'Unit: TemplatePhase',
  setup: ->
    setupApp()
    Ember.run =>
      testPhase = ETahi.TemplatePhase.create(name: "First Phase")
      testTasks = ["A Task", "Another"].map (taskType) ->
        ETahi.TemplateTask.create type: taskType, phase: testPhase
      testPhase.set('tasks', testTasks)
      newPhase = testPhase.copy()

test "#copy creates a new TemplatePhase object", ->
  ok(newPhase != testPhase)
  equal newPhase.get('name'), testPhase.get('name')

test "#copy makes new copies of the old tasks", ->
  newTasks = newPhase.get('tasks')
  oldTasks = testPhase.get('tasks')
  ok(newTasks != oldTasks)
  equal newTasks.get('firstObject.type'), oldTasks.get('firstObject.type')

