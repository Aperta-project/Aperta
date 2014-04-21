#= require test_helper

testPhases = undefined
testTemplate = undefined

module 'Unit: ManuscriptManagerTemplate',
  setup: ->
    phase = name: 'First Phase', task_types: ['ATask', 'AnotherTask']
    @testThing = 5
    template =
      name: 'A name'
      id: 1
      paper_type: 'A type'
      template:
        phases: [phase]

    Ember.run =>
      testTemplate = ETahi.ManuscriptManagerTemplate.create(template)
      testPhases = testTemplate.get('phases')

test '#init creates phase objects for the phases in a template', ->
  equal testPhases.length, 1
  equal testPhases.get('firstObject.name'), 'First Phase'

test '#init creates task objects for the task types in a phase', ->
  tasks = testPhases.get('firstObject.tasks')
  equal tasks.get('length'), 2
  equal tasks.get('firstObject.title'), 'ATask'

test "#init sets the paperType", ->
  equal testTemplate.get('paperType'), 'A type'

test "#init sets the template property to null", ->
  equal testTemplate.get('template'), null


test "#templateJSON serializes the template's state.", ->
  testData = {
    id: 1,
    name: 'A name',
    paper_type: 'A type'
    template: phases: [ {name: 'First Phase', task_types: ['ATask', 'AnotherTask']}]
  }
  deepEqual testTemplate.get('templateJSON'), testData


