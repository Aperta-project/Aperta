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
      journal_id: 5
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

test "#init sets the journalId", ->
  equal testTemplate.get('journalId'), 5

test "#templateJSON serializes the template's state.", ->
  testData = {
    id: 1,
    name: 'A name',
    paper_type: 'A type'
    template: phases: [ {name: 'First Phase', task_types: ['ATask', 'AnotherTask']}]
  }
  deepEqual testTemplate.get('templateJSON'), testData

test "#savePayload sets the request type to PUT if the template has an id", ->
  savePayload = testTemplate.get('savePayload')
  equal savePayload.type, "PUT"

test "#savePayload sets the request type to POST if the template has no id", ->
  testTemplate.set('id', null)
  savePayload = testTemplate.get('savePayload')
  equal savePayload.type, "POST"

test "#savePayload sets the url to the update endpoint if the template has an id", ->
  savePayload = testTemplate.get('savePayload')
  equal savePayload.url, "/manuscript_manager_templates/1"

test "#savePayload sets the url to the create endpoint if the template has no id", ->
  testTemplate.set('id', null)
  savePayload = testTemplate.get('savePayload')
  equal savePayload.url, "/manuscript_manager_templates/"

test "#savePayload includes the journal id as part of the data object", ->
  savePayload = testTemplate.get('savePayload')
  data = JSON.parse(savePayload.data)
  equal data.journal_id, 5

