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

test "#ajaxPayload sets the request type to PUT if the template has an id", ->
  ajaxPayload = testTemplate.get('ajaxPayload')
  equal ajaxPayload.type, "PUT"

test "#ajaxPayload sets the request type to POST if the template has no id", ->
  testTemplate.set('id', null)
  ajaxPayload = testTemplate.get('ajaxPayload')
  equal ajaxPayload.type, "POST"

test "#ajaxPayload sets the url to the update endpoint if the template has an id", ->
  ajaxPayload = testTemplate.get('ajaxPayload')
  equal ajaxPayload.url, "/manuscript_manager_templates/1"

test "#ajaxPayload sets the url to the create endpoint if the template has no id", ->
  testTemplate.set('id', null)
  ajaxPayload = testTemplate.get('ajaxPayload')
  equal ajaxPayload.url, "/manuscript_manager_templates/"

test "#ajaxPayload includes the journal id as part of the data object", ->
  ajaxPayload = testTemplate.get('ajaxPayload')
  data = JSON.parse(ajaxPayload.data)
  equal data.journal_id, 5

